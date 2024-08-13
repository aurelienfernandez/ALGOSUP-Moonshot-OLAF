import { defineStorage } from '@aws-amplify/backend';


export const storage = defineStorage({
    name: 'olaf-user',
    access: (allow) => ({
      'uploads/*': [
        allow.guest.to(['read']),
        allow.entity('identity').to(['read', 'write', 'delete']),
        allow.authenticated.to(['read','write']),
        allow.guest.to(['read', 'write'])
      ],
    })
  });