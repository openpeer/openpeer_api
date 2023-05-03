# OpenPeer API

This repository contains the Ruby on Rails API for the OpenPeer app, a self-custody platform for peer-to-peer trading of crypto assets.

The frontend repository for the app can be found [here](https://github.com/Minke-Labs/openpeer/tree/main/app).

## Getting Started

To run the app locally, follow these steps:

1. Install the necessary dependencies by running `bundle install`
2. Create the database and run the migrations and seeds by running `rake db:create db:migrate db:seed`
3. Start the server by running `rails s -p 5000`

## Updating Webhooks URL

To update the contracts webhooks URL, run the following command:

```bash
rake "deployer_contract:update_webhook[https://eed6-2001-8a0-72b6-1d00-ecac-aac4-8d2b-b68d.eu.ngrok.io]"
```

## Updating Escrows ABI

To update the escrows ABI, run the following command:

```bash
rake "escrows_contract:update[../openpeer/app/abis/OpenPeerEscrow.json]"
```

## The OpenPeer Protocol

OpenPeer uses escrow contracts to enable peer-to-peer trades in stablecoins without the need for a centralized intermediary. Here's how it works:

1. A seller interacts with the OpenPeer Deployer contract to deploy an individual escrow contract that holds their funds. This ensures that contracts created through the protocol are identifiable and not tampered with by bad actors.

2. The seller posts an ad on the OpenPeer app to sell their stablecoins, stating the available amount, minimum and maximum trade sizes, acceptable payment methods, and any price rules.

3. The buyer responds to the ad to exchange their local currency for stablecoins. Once the seller accepts the offer, they deploy a contract that escrows their funds. The buyer is then sent a notification with the seller's payment details and instructions on how to make the payment. A payment window of 24 hours begins, during which time the crypto is held in escrow.

4. The buyer confirms when they make the payment, and signs a transaction to ensure that the escrowed funds cannot be withdrawn back to the seller without arbitration. A notification is sent to the seller that payment has been made and to release the escrowed stablecoins.

5. Upon receipt of the payment, the seller signs a transaction to release the escrowed funds from the contract, and the buyer receives the stablecoins.

6. If either party believes that the other has violated the agreed upon terms, they can initiate a dispute through the OpenPeer UI. The protocol provides a mechanism for dispute resolution by facilitating communication between the two parties. If the dispute cannot be resolved through communication or mediation, a panel of arbitrators vetted and approved by the OpenPeer community will make a binding decision.

Overall, the OpenPeer protocol is designed to provide a fair and reliable way for buyers and sellers to trade in stablecoins without the need for a centralized intermediary.
