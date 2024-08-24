import { defineStorage } from '@aws-amplify/backend';


export const storage = defineStorage({
  name: 'olaf-s3',
  access: (allow) => ({
    'users/*': [
      allow.guest.to(['read']),
      allow.entity('identity').to(["get", "list", "write", "delete"]),
      allow.authenticated.to(["get", "list", "write", "delete"]),
    ],
  })
});