import { defineAuth, defineStorage } from '@aws-amplify/backend';

/**
 * Define and configure your auth resource
 * @see https://docs.amplify.aws/gen2/build-a-backend/auth
 */
export const auth = defineAuth({
  loginWith: {
    email: true,
  },

  userAttributes: {
    profilePicture: {
      mutable: true,
      required: false,
    }

  },
});
export const storage = defineStorage({
  name: 'olaf-s3',
  access: (allow) => ({
    '*': [
      allow.authenticated.to(['get']),
      allow.authenticated.to(['read']),
      allow.authenticated.to(['write']),
      allow.authenticated.to(['delete']),
      allow.authenticated.to(['list']) 
    ]
  })
});
