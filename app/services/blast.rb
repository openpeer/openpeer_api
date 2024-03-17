module Blast
  DEPLOYER_EVENT = 'event ContractCreated(address _seller, address _deployment)'
  ESCROW_EVENTS = [
    'event EscrowCreated(bytes32 indexed _orderHash)',
    'event Released(bytes32 indexed _orderHash)',
    'event CancelledByBuyer(bytes32 indexed _orderHash)',
    'event SellerCancelDisabled(bytes32 indexed _orderHash)',
    'event CancelledBySeller(bytes32 indexed _orderHash)',
    'event DisputeOpened(bytes32 indexed _orderHash, address indexed _sender)',
    'event DisputeResolved(bytes32 indexed _orderHash, address indexed _winner)'
  ]
  CHAIN_ID = 81457
end
