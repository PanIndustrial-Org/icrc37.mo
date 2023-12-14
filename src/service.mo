module {
  public type Value = { 
    #Blob : Blob; 
    #Text : Text; 
    #Nat : Nat;
    #Int : Int;
    #Array : [Value]; 
    #Map : [(Text, Value)]; 
  };

  // Account Types
  public type Subaccount = Blob;

  /// As descrived by ICRC1
  public type Account = {
    owner: Principal;
    subaccount:  ?Subaccount;
  };

  public type TokenApproval = {
    token_id: Nat;
    approval_info: ApprovalInfo;
  };

  public type ApprovalInfo = {
    from_subaccount : ?Blob;
    spender : Account;             // Approval is given to an ICRC Account
    memo :  ?Blob;
    expires_at : ?Nat64;
    created_at_time : ?Nat64; 
  };

  public type CollectionApproval = ApprovalInfo;

  public type TransferFromArgs = {
    spender_subaccount: ?Blob; // the subaccount of the caller (used to identify the spender)
    from : Account;
    to : Account;
    token_ids : [Nat];
    // type: leave open for now
    memo : ?Blob;
    created_at_time : ?Nat64;
  };

  public type TransferFromResponseItem = {
    token_id : Nat;
    transfer_result :{
      #Ok: Nat;
      #Err: TransferFromError
    };
  };

  type TransferFromBatchError = {
    #InvalidRecipient;
    #TooOld;
    #CreatedInFuture :  { ledger_time: Nat64 };
    #GenericError :  { error_code : Nat; message : Text };
};

  public type TransferFromError = {
    #NonExistingTokenId;
    #Unauthorized;
    #Duplicate : { duplicate_of : Nat };
    #GenericError : { 
      error_code : Nat; 
      message : Text 
    };
  };

  public type TransferFromResponse = {
    #Ok: [TransferFromResponseItem];
    #Err: TransferFromBatchError;
  };

   public type ApprovalResponse = {
    #Ok : [ApprovalResponseItem];
    #Err : ApproveTokensBatchError;
  };

  public type ApprovalResult =  {
    #Ok: Nat;
    #Err: ApproveTokensError;
  };

  public type ApproveTokensError = {
    #NonExistingTokenId;
    #Unauthorized;
    #TooOld;
    #CreatedInFuture : { ledger_time: Nat64 };
    #GenericError : { error_code : Nat; message : Text };
    #Duplicate : { duplicate_of : Nat };
  };

  public type ApprovalResponseItem = {
    token_id : Nat;
    approval_result :ApprovalResult;
  };

  public type ApproveTokensBatchError = {
    #TooOld;
    #CreatedInFuture : { ledger_time: Nat64 };
    #GenericError : { error_code : Nat; message : Text };
  };

   public type ApprovalCollectionResponse = {
    #Ok: Nat;
    #Err: ApproveCollectionError;
  };

  public type ApproveCollectionError = {
    #TooOld;
    #CreatedInFuture : { ledger_time: Nat64 };
    #GenericError : { error_code : Nat; message : Text };
    #Duplicate : { duplicate_of : Nat };
  };

  public type RevokeTokensArgs = {
      token_ids : [Nat];
      from_subaccount : ?Blob;
      spender : ?Account;
      memo: ?Blob;
      created_at_time : ?Nat64
  };

  public type RevokeTokensBatchError = {
    #TooOld;
    #CreatedInFuture : { ledger_time: Nat64 };
    #GenericError : { error_code : Nat; message : Text };
  };

  public type RevokeTokensResponse = {
    #Ok: [RevokeTokensResponseItem];
    #Err: RevokeTokensBatchError
  };

  public type RevokeTokensResult = {
    #Ok : Nat; 
    #Err : RevokeTokensError 
  };

   public type RevokeTokensError = {
      #NonExistingTokenId;
      #Unauthorized;
      #ApprovalDoesNotExist;
      #GenericError : { error_code : Nat; message : Text };
      #Duplicate : { duplicate_of : Nat };
  };

  public type RevokeTokensResponseItem = {
      token_id: Nat;
      spender: ?Account;
      revoke_result: RevokeTokensResult;
  };

  public type RevokeCollectionArgs = {
      from_subaccount: ?Blob;
      spender: ?Account;
      memo: ?Blob;
      created_at_time : ?Nat64;
  };

  public type RevokeCollectionResponseItem = {
      spender: ?Account;
      revoke_result: RevokeTokensResult;
  };

  public type RevokeCollectionResponse = {
    #Ok: [RevokeCollectionResponseItem];
    #Err: RevokeCollectionBatchError;
  };

  public type RevokeCollectionBatchError = {
    #TooOld;
    #CreatedInFuture : { ledger_time: Nat64 };
    #GenericError : { error_code : Nat; message : Text };
  };

  public type Service = actor {
    icrc30_metadata : shared query () -> async [(Text, Value)];
    icrc30_max_approvals_per_token_or_collection: shared query ()-> async ?Nat;
    icrc30_max_revoke_approvals:  shared query ()-> async ?Nat;
    icrc30_is_approved : shared query (spender: Account, from_subaccount: ?Blob, token_id : Nat) -> async Bool;
    icrc30_get_approvals : shared query (token_ids : [Nat], prev : ?TokenApproval, take :  ?Nat) -> async [TokenApproval];
    icrc30_get_collection_approvals : shared query (owner : Account, prev : ?CollectionApproval, take : ?Nat) -> async [CollectionApproval];
    icrc30_transfer_from: shared (TransferFromArgs)-> async TransferFromResponse;
    icrc30_approve: shared (token_ids: [Nat], approval: ApprovalInfo)-> async ApprovalResponse;
    icrc30_approve_collection: shared (approval: ApprovalInfo)-> async ApprovalCollectionResponse;
    icrc30_revoke_token_approvals: shared (RevokeTokensArgs) -> async RevokeTokensResponse;
    icrc30_revoke_collection_approvals: shared (RevokeCollectionArgs) -> async RevokeCollectionResponse;
  };

}