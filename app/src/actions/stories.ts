import { Action } from 'redux';
import { ListStoriesRequest, ListStoriesResponse, Story } from '../proto/hackernews_pb';
import { GrpcAction, grpcRequest } from '../middleware/grpc';
import { grpc } from '@improbable-eng/grpc-web';
import { HackerNewsService } from '../proto/hackernews_pb_service';

export const STORIES_INIT = 'STORIES_INIT';
export const ADD_STORY = 'ADD_STORY';
export const SELECT_STORY = 'SELECT_STORY';

type AddStory = {
  type: typeof ADD_STORY,
  payload: Story,
};
export const addStory = (story: Story) => ({ type: ADD_STORY, payload: story });

type ListStoriesInit = {
  type: typeof STORIES_INIT,
};
export const listStoriesInit = (): ListStoriesInit => ({type: STORIES_INIT});

export const listStories = () => {
  return grpcRequest<ListStoriesRequest, ListStoriesResponse>({
    request: new ListStoriesRequest(),
    onStart: () => listStoriesInit(),
    onEnd: (code: grpc.Code, message: string | undefined, trailers: grpc.Metadata): Action | void => {
      console.log(code, message, trailers);
      return;
    },
    host: 'http://10.0.0.75:8900',
    methodDescriptor: HackerNewsService.ListStories,
    onMessage: message => {
      const story = message.getStory();
      if (story) {
        return addStory(story);
      }
      return;
    },
  });
};

type SelectStory = {
  type: typeof SELECT_STORY,
  payload: number,
};
export const selectStory = (storyId: number): SelectStory => ({ type: SELECT_STORY, payload: storyId });

export type StoryActionTypes =
  | ListStoriesInit
  | AddStory
  | SelectStory
  | GrpcAction<ListStoriesRequest, ListStoriesResponse>;
