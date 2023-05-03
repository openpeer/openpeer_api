# README

Ruby on Rails API repository for the [OpenPeer app](https://app.openpeer.xyz).
[Frontend repository](https://github.com/Minke-Labs/openpeer/tree/main/app)

How to run this app?

```bash
bundle install
rake db:create db:migrate db:seed
rails s -p 5000
```

How to update the contracts webhooks URL?

```bash
rake "deployer_contract:update_webhook[https://eed6-2001-8a0-72b6-1d00-ecac-aac4-8d2b-b68d.eu.ngrok.io]"
```

How to update the escrows ABI?

```bash
rake "escrows_contract:update[../openpeer/app/abis/OpenPeerEscrow.json]"
```
