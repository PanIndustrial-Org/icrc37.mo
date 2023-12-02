import MigrationTypes "./migrations/types";
import Migration "./migrations";

import Array "mo:base/Array";
import D "mo:base/Debug";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Result "mo:base/Result";
import Blob "mo:base/Blob";
import Text "mo:base/Text";
import RepIndy "mo:rep-indy-hash";

//todo: switch to mops
import ICRC7 "mo:icrc7";

module {

  /// A debug channel to toggle logging for various aspects of NFT operations.
  ///
  /// Each field corresponds to an operation such as transfer or indexing, allowing
  /// developers to enable or disable logging during development.
  let debug_channel = {
    announce = true;
    indexing = true;
    transfer = true;
    querying = true;
    approve = true;
    revoke = true;
  };

  /// Access to Map v9.0.1
  public let Map =                  MigrationTypes.Current.Map;

  /// Access to Set v9.0.1
  public let Set =                  MigrationTypes.Current.Set;

  /// Access to Vector
  public let Vec =                  MigrationTypes.Current.Vec;

  /// Hashing function for account IDs as defined by the `ICRC7` module. Used for Account based Maps
  public let ahash =                ICRC7.ahash;

  /// Hashing function for approval maps.
  let apphash =                     MigrationTypes.Current.apphash;

  /// Hashing function for Maps of ?Nat
  let nullnathash =                 MigrationTypes.Current.nullnathash;

  /// Account Equality.
  public let account_eq =           ICRC7.account_eq;

  /// Compare functions for sorting accounts.
  let account_compare =             ICRC7.account_compare;

  public type CurrentState =        MigrationTypes.Current.State;
  public type State =               MigrationTypes.State;
  public type Stats =               MigrationTypes.Current.Stats;
  public type InitArgs =            MigrationTypes.Args;
  public type Error =               MigrationTypes.Current.Error;
  public type Account =             MigrationTypes.Current.Account;
  public type LedgerInfo =          MigrationTypes.Current.LedgerInfo;
  public type NFT =                 ICRC7.NFT;
  public type ApprovalInfo =        MigrationTypes.Current.ApprovalInfo;
  public type Value =               MigrationTypes.Current.Value;
  public type Indexes =             MigrationTypes.Current.Indexes;
  public type Environment =         MigrationTypes.Current.Environment;
  public type UpdateLedgerInfoRequest = MigrationTypes.Current.UpdateLedgerInfoRequest;
  
  public type ApprovalResponse =            MigrationTypes.Current.ApprovalResponse;
  public type ApprovalResult =              MigrationTypes.Current.ApprovalResult;
  public type ApprovalCollectionResponse =  MigrationTypes.Current.ApprovalCollectionResponse;
  public type ApprovalResponseItem =        MigrationTypes.Current.ApprovalResponseItem;
  
  public type TransferFromArgs =                MigrationTypes.Current.TransferFromArgs;
  public type TransferFromResponse =            MigrationTypes.Current.TransferFromResponse;
  public type TransferFromResponseItem =        MigrationTypes.Current.TransferFromResponseItem;
  public type TransferFromError =               MigrationTypes.Current.TransferFromArgs;
  public type TransferNotification =        ICRC7.TransferNotification;
  public type RevokeTokensArgs =            MigrationTypes.Current.RevokeTokensArgs;
  public type RevokeTokensError =           MigrationTypes.Current.RevokeTokensError;
  public type RevokeTokensResponse =        MigrationTypes.Current.RevokeTokensResponse;
  public type RevokeTokensResult =          MigrationTypes.Current.RevokeTokensResult;
  public type RevokeTokensResponseItem =    MigrationTypes.Current.RevokeTokensResponseItem;
  public type RevokeCollectionArgs =            MigrationTypes.Current.RevokeCollectionArgs;
  public type RevokeCollectionError =           MigrationTypes.Current.RevokeCollectionError;
  public type RevokeCollectionResponse =        MigrationTypes.Current.RevokeCollectionResponse;
  public type RevokeCollectionResult =          MigrationTypes.Current.RevokeCollectionResult;
  public type RevokeCollectionResponseItem =    MigrationTypes.Current.RevokeCollectionResponseItem;
  public type TokenApproval =                   MigrationTypes.Current.TokenApproval; 
  public type CollectionApproval =              MigrationTypes.Current.CollectionApproval;

  public type TokenApprovalNotification =              MigrationTypes.Current.TokenApprovalNotification;
  public type CollectionApprovalNotification =              MigrationTypes.Current.CollectionApprovalNotification;
  public type RevokeTokenNotification =              MigrationTypes.Current.RevokeTokenNotification;
  public type RevokeCollectionNotification =              MigrationTypes.Current.RevokeCollectionNotification;
  public type TransferFromNotification =              MigrationTypes.Current.TransferFromNotification;

  public type TokenApprovedListener =              MigrationTypes.Current.TokenApprovedListener;
  public type CollectionApprovedListener =              MigrationTypes.Current.CollectionApprovedListener;
  public type TokenApprovalRevokedListener =              MigrationTypes.Current.TokenApprovalRevokedListener;
  public type CollectionApprovalRevokedListener =              MigrationTypes.Current.CollectionApprovalRevokedListener;
  public type TransferFromListener =              MigrationTypes.Current.TransferFromListener;

  let default_take = 10000;

  /// Function to create an initial state for the Approval ICRC30 management.
  public func initialState() : State {#v0_0_0(#data)};

  /// Current ID Version of the Library, used for Migrations
  public let currentStateVersion = #v0_1_0(#id);

  /// Function to initialize a function and migrate it to the current version.
  public let init = Migration.migrate;

  /// Helper function to determine if a Too Old response is present
  public func collectionRevokeIsTooOld(result : RevokeCollectionResponse) : Bool {
    
      switch(result){
        case(#Err(#TooOld)){
          return true;
        };
        case(_){};
      };
   
    return false;
  };

  /// Helper function to determine if a Too Old response is present
  public func tokenRevokeIsTooOld(result : RevokeTokensResponse) : Bool{
    
      switch(result){
        case(#Err(#TooOld)){
          return true;
        };
        case(_){};
      };
    return false;
  };

  /// Helper function to determine if a Too Old response is in the future
  public func collectionRevokeIsInFuture(result : RevokeCollectionResponse) : Bool{
    
      switch(result){
        case(#Err(#CreatedInFuture(err))){
           return true;
        };
        case(_){};
      };
    
    return false;
  };

  /// Helper function to determine if a Too Old response is in the future
  public func tokenRevokeIsInFuture(result : RevokeTokensResponse) : Bool{
    
      switch(result){
        case(#Err(#CreatedInFuture(val))){
          return true;
        };
        case(_){};
      };
    
    return false;
  };

  public type Service = actor {
    icrc30_metadata : shared query () -> async [(Text, Value)];
    icrc30_max_approvals_per_token_or_collection: shared query ()-> async ?Nat;
    icrc30_max_revoke_approvals:  shared query ()-> async ?Nat;
    icrc30_is_approved : shared query (spender: Account, from_subaccount: ?Blob, token_id : Nat) -> async Bool;
    icrc30_get_token_approvals : shared query (token_ids : [Nat], prev : ?TokenApproval, take :  ?Nat) -> async [TokenApproval];
    icrc30_get_collection_approvals : shared query (owner : Account, prev : ?CollectionApproval, take : ?Nat) -> async [CollectionApproval];
    icrc30_transfer_from: shared (TransferFromArgs)-> async TransferFromResponse;
    icrc30_approve: shared (token_ids: [Nat], approval: ApprovalInfo)-> async ApprovalResponse;
    icrc30_approve_collection: shared (approval: ApprovalInfo)-> async ApprovalCollectionResponse;
    icrc30_revoke_token_approvals: shared (RevokeTokensArgs) -> async RevokeTokensResponse;
    icrc30_revoke_collection_approvals: shared (RevokeCollectionArgs) -> async RevokeCollectionResponse;
  };

  /// #class ICRC30 
  /// Initializes the state of the ICRC30 class.
  /// - Parameters:
  ///     - stored: `?State` - An optional initial state to start with; if `null`, the initial state is derived from the `initialState` function.
  ///     - canister: `Principal` - The principal of the canister where this class is used.
  ///     - environment: `Environment` - The environment settings for various ICRC standards-related configurations.
  /// - Returns: No explicit return value as this is a class constructor function.
  ///
  /// The `ICRC30` class encapsulates the logic for managing approvals and transfers of NFTs.
  /// Within the class, we have various methods such as `get_ledger_info`, `approve_transfers`, 
  /// `is_approved`, `get_token_approvals`, `revoke_collection_approvals`, and many others
  /// that assist in handling the ICRC-30 standard functionalities like getting and setting 
  /// approvals, revoking them, and performing transfers of NFTs.
  ///
  /// The methods often utilize helper functions like `testMemo`, `testExpiresAt`, `testCreatedAt`, 
  /// `revoke_approvals`, `cleanUpApprovals`, `update_ledger_info`, `revoke_collection_approval`, 
  /// `approve_transfer`, `transfer_token`, `revoke_token_approval` and others that perform 
  /// specific operations such as validation of data and performing the necessary changes to the approvals 
  /// and the ledger based on the NFT transactions.
  ///
  /// Event listeners and clean-up routines are also defined to maintain the correct state 
  /// of approvals after transfers and to ensure the system remains within configured limitations.
  ///
  /// The `ICRC30` class allows for detailed ledger updates using `update_ledger_info`, 
  /// querying for different approval states, and managing the transfer of tokens.
  ///    
  /// Additional functions like `get_stats` provide insight into the current state of NFT approvals.
  public class ICRC30(stored: ?State, canister: Principal, environment: Environment){

    var state : CurrentState = switch(stored){
      case(null) {
        let #v0_1_0(#data(foundState)) = init(initialState(),currentStateVersion, null, canister);
        foundState;
      };
      case(?val) {
        let #v0_1_0(#data(foundState)) = init(val,currentStateVersion, null, canister);
        foundState;
      };
    };

    private let token_approved_listeners = Vec.new<(Text, TokenApprovedListener)>();
    private let collection_approved_listeners = Vec.new<(Text, CollectionApprovedListener)>();
     private let token_revoked_listeners = Vec.new<(Text, TokenApprovalRevokedListener)>();
    private let collection_revoked_listeners = Vec.new<(Text, CollectionApprovalRevokedListener)>();
    private let transfer_from_listeners = Vec.new<(Text, TransferFromListener)>();

    public let migrate = Migration.migrate;
    public let TokenErrorToCollectionError = MigrationTypes.Current.TokenErrorToCollectionError;

    /// Gets ledger information for the associated ICRC-30 NFT collection.
    /// - Returns: `LedgerInfo` - The current ledger information for the ICRC-30 NFT collection.
    public func get_ledger_info() :  LedgerInfo {
      return state.ledger_info;
    };

    /// Gets indexing information relating to owner approvals.
    /// - Returns: `Indexes` - Indexes relating to the approvals set by various owners against their accounts.
    public func get_indexes() :  Indexes {
      return state.indexes;
    };

    /// Gets state information relating to owner approvals.
    /// - Returns: `State` - Indexes relating to the approvals set by various owners against their accounts.
    public func get_state() :  CurrentState {
      return state;
    };

    /// Approves transfers for specified token IDs.
    /// - Parameters:
    ///     - caller: `Principal` - The principal of the user initiating the approval action.
    ///     - token_ids: `[Nat]` - An array of token IDs the user is granting approval for.
    ///     - approval: `ApprovalInfo` - The approval information including spender and optional expiry.
    /// - Returns: `Result<[ApprovalResponseItem], Text>` - A result containing either a list of approval response items or an error message in text.
    public func approve_transfers(caller: Principal, token_ids: [Nat], approval: ApprovalInfo) : Result.Result<ApprovalResponse, Text> {

      //check that the batch isn't too big
      let safe_batch_size = environment.icrc7.get_ledger_info().max_update_batch_size;

       //test that the memo is not too large
      let ?(memo) = testMemo(approval.memo) else return #err("invalid memo. must be less than " # debug_show(environment.icrc7.get_ledger_info().max_memo_size) # " bits");

      if(token_ids.size() == 0) return #err("empty token_ids");

      if(hasDupes(token_ids)) return #err("duplicate tokens in token_ids");

      //test that the expires is not in the past
      let ?(expires_at) = testExpiresAt(approval.expires_at) else return #err("already expired");

      //check from and spender account not equal
      if(account_eq({owner = caller; subaccount = approval.from_subaccount}, approval.spender)){
        return #err("cannot approve tokens to same account");
      };

      let current_approvals = switch(Map.get(state.indexes.owner_to_approval_account, ahash, {owner = caller; subaccount = approval.from_subaccount})){
        case(?val){
          Set.size(val);
        };
        case(null) 0;
      };

      debug if(debug_channel.approve) D.print("number of approvals" # debug_show(current_approvals));

      if(current_approvals >= state.ledger_info.max_approvals_per_token_or_collection){
        return #err("Too many approvals from account" # debug_show({owner = caller; subaccount = approval.from_subaccount}))
      };

      //make sure the approval is not too old or too far in the future
      let created_at_time = switch(testCreatedAt(approval.created_at_time, environment)){
        case(#ok(val)) val;
        case(#Err(#TooOld)) return #ok(#Err(#TooOld));
        case(#Err(#InTheFuture(val))) return  #ok(#Err(#CreatedInFuture({ledger_time = Nat64.fromNat(Int.abs(environment.get_time()))})));
      };
      
      return #ok(#Ok(Array.map<Nat, ApprovalResponseItem>(token_ids,  func(x) : ApprovalResponseItem { 
        let result = approve_transfer(environment, caller, ?x, approval);
        
        switch(result.0){
          case(null) {// should be unreachable;
            return {token_id = x; approval_result = #Err(#GenericError({error_code = 8; message = "unreachable null token"}))} : ApprovalResponseItem; 
          }; 
          case(?val) return ({token_id = val; approval_result = result.1} : ApprovalResponseItem);
        };
      })));
      
    };

    private func testMemo(val : ?Blob) : ??Blob{
      switch(val){
        case(null) return ?null;
        case(?val){
          let max_memo = environment.icrc7.get_ledger_info().max_memo_size;
          if(val.size() > max_memo){
            return null;
          };
          return ??val;
        };
      };
    };

    private func testExpiresAt(val : ?Nat64) : ??Nat64{
      switch(val){
        case(null) return ?null;
        case(?val){
          if(Nat64.toNat(val) < environment.get_time()){
            return null;
          };
          return ??val;
        };
      };
    };

    private func testCreatedAt(val : ?Nat64, environment: Environment) : {
      #ok: ?Nat64;
      #Err: {#TooOld;#InTheFuture: Nat64};
      
    }{
      switch(val){
        case(null) return #ok(null);
        case(?val){
          if(Nat64.toNat(val) > environment.get_time() + environment.icrc7.get_ledger_info().permitted_drift){
            return #Err(#InTheFuture(Nat64.fromNat(Int.abs(environment.get_time()))));
          };
          if(Nat64.toNat(val) < environment.get_time() - environment.icrc7.get_ledger_info().permitted_drift){
            return #Err(#TooOld);
          };
          return #ok(?val);
        };
      };
    };


    /// Checks if the specified account is approved for the provided token.
    /// - Parameters:
    ///     - spender: `Account` - The account whose approval status is being queried.
    ///     - from_subaccount: `?Blob` - The optional subaccount from which the check is done.
    ///     - token_id: `Nat` - The ID of the token being checked.
    /// - Returns: `Bool` - A boolean indicating if the spender is approved for the specified token.
    public  func is_approved(spender : Account, from_subaccount: ?Blob, token_id: Nat) : Bool {

      debug if(debug_channel.announce) D.print("is_approved " # debug_show(spender, from_subaccount, token_id));

      //look in collection approvals
      switch(Map.get<(?Nat,Account), ApprovalInfo>(state.token_approvals, apphash, (null, spender))){
        case(null){};
        case(?val){
          if(val.from_subaccount == from_subaccount) return true;
        };
      };
       

      //look in direct approvals
      
      switch(Map.get<(?Nat,Account), ApprovalInfo>(state.token_approvals, apphash, (?token_id, spender))){
        case(null){};
        case(?val){
          if(val.from_subaccount == from_subaccount) return true;
        };
      };
       
      return false;
    };

    /// Gets token approvals given specific token IDs and paginates results based on previous approvals and page size.
    /// - Parameters:
    ///     - token_ids: `[Nat]` - An array of token IDs to get approvals for.
    ///     - prev: `?TokenApproval` - An optional approval to use as the starting point for pagination.
    ///     - take: `?Nat` - The number of approvals to be fetched, effectively the page size.
    /// - Returns: `Result<[TokenApproval], Text>` - Either a list of token approvals or an error message.
    public func get_token_approvals(token_ids: [Nat], prev: ?TokenApproval, take: ?Nat) : Result.Result<[TokenApproval], Text>{

      
      if(token_ids.size() > environment.icrc7.get_ledger_info().max_query_batch_size) return #err("too many tokenids in qurey. Max is " # Nat.toText(environment.icrc7.get_ledger_info().max_query_batch_size));
        
      
      let results = Vec.new<TokenApproval>();

      //sort the tokenIDs
      let sorted_tokens = Array.sort<Nat>(token_ids, Nat.compare);

      var tracker = 0;
      var bFound = switch(prev){
        case(null) true;
        case(?val) false;
      };

      let max_take_value = environment.icrc7.get_ledger_info().max_take_value;
      
      switch(take){
        case(?take){
          if(take > max_take_value) return #err("too many in take. Max is " # Nat.toText(max_take_value));
        };
        case(null){

        };
      };

      let default_take_value = environment.icrc7.get_ledger_info().default_take_value;

      var targetCount = switch(take){
        case(?val) val;
        case(null) default_take_value;
      };

      for(thisToken in sorted_tokens.vals()){
        switch(Map.get<?Nat, Set.Set<Account>>(state.indexes.token_to_approval_account, nullnathash, ?thisToken)){
          case(null){};
          case(?set){
            let sorted = Iter.sort<Account>(Set.keys(set), account_compare);
            for(thisAccount in sorted){

              if(bFound == false){
                switch(prev){
                  case(null){}; //unreachable
                  case(?prev){
                    if((Nat.compare(thisToken, prev.token_id) == #equal or (Nat.compare(thisToken, prev.token_id) == #greater) and account_compare(thisAccount, prev.approval_info.spender) == #greater)){
                      bFound := true;
                    };
                  };
                };
              };
              switch(Map.get<(?Nat, Account), ApprovalInfo>(state.token_approvals, apphash, (?thisToken, thisAccount))){
                case(null){};//unreachable
                case(?foundApproval){
                  if(bFound){
                    Vec.add(results, {
                      token_id = thisToken;
                      approval_info = foundApproval;
                    });
                    if(Vec.size(results) == targetCount){
                      return #ok(Vec.toArray<TokenApproval>(results));
                    };
                  };
                };
              };
            };
          };
        };
      };

      return #ok(Vec.toArray<TokenApproval>(results)); 

    };

    /// Gets collection approvals for the specified owner and paginates results based on previous approvals and page size.
    /// - Parameters:
    ///     - owner: `Account` - The account for which to get collection approvals.
    ///     - prev: `?CollectionApproval` - An optional approval to use as the starting point for pagination.
    ///     - take: `?Nat` - The number of approvals to be fetched, effectively the page size.
    /// - Returns: `Result<[CollectionApproval], Text>` - Either a list of collection approvals or an error message.
    public func get_collection_approvals(owner: Account, prev: ?CollectionApproval, take: ?Nat) : Result.Result<[CollectionApproval], Text>{
      
      let results = Vec.new<CollectionApproval>();

      let ?approvals = Map.get<Account, Set.Set<(?Nat, Account)>>(state.indexes.owner_to_approval_account, ahash, owner) else return #ok([]);

      var bFound = switch(prev){
        case(null) true;
        case(?val) false;
      };

      let max_take_value = environment.icrc7.get_ledger_info().max_take_value;

      switch(take){
        case(?take){
          if(take > max_take_value) return #err("too many in take. Max is " # Nat.toText(max_take_value));
        };
        case(null){

        };
      };

      let default_take_value = environment.icrc7.get_ledger_info().default_take_value;

      var targetCount = switch(take){
        case(?val) val;
        case(null) default_take_value;
      };

      let sorted_accounts = Iter.sort<(?Nat, Account)>(Set.keys(approvals), func(a : (?Nat, Account), b : (?Nat, Account)){
        return account_compare(a.1, b.1);
      });

      debug if(debug_channel.querying) D.print("paginating collection approvals" # debug_show(targetCount, max_take_value, bFound));

      for(thisItem in sorted_accounts){
        if(thisItem.0 == null){
          if(bFound == false){
            switch(prev){
              case(null){}; //unreachable
              case(?prev){
                if(account_compare(thisItem.1, prev.spender) == #greater){
                  bFound := true;
                };
              };
            };
          };
          if(bFound){
            switch(Map.get<(?Nat, Account), ApprovalInfo>(state.token_approvals, apphash, (null, thisItem.1))){
              case(null) {}; //unreachable
              case(?foundItem){
                Vec.add<CollectionApproval>(results, foundItem);
                if(Vec.size(results) == targetCount){
                  return #ok(Vec.toArray<CollectionApproval>(results));
                };
              };
            };
            
          };
        };
      };

      return #ok(Vec.toArray<CollectionApproval>(results)); 
    };

    /// Cleans up approvals for collections that have exceeded a certain threshold.
    public func cleanUpApprovalsRoutine() : () {
      if(Map.size<(?Nat, Account), ApprovalInfo>(state.token_approvals) > state.ledger_info.max_approvals){
        cleanUpApprovals(state.ledger_info.settle_to_approvals);
      };
    };

    /// Cleans up approvals until the Map is reduced to the size in remaining.
    /// - Parameters:
    ///     - remaining: `Nat` - The number of approvals you want the Map size reduced to
    public func cleanUpApprovals(remaining: Nat) : (){
      //this naievly delete the oldest items until the collection is equal or below the remaining value
      let memo = Text.encodeUtf8("icrc30_system_clean");
    
      label clean for(thisItem in Map.entries<(?Nat, Account), ApprovalInfo>(state.token_approvals)){

        switch(thisItem.0.0){
          //collection approvals
          case(null){
            let result = revoke_approvals(thisItem.0.0, ?thisItem.0.1, thisItem.1.from_subaccount, null);

            label proc for(thisItem in result.vals()){
              let trx = Vec.new<(Text, Value)>();
              let trxtop = Vec.new<(Text, Value)>();

              Vec.add(trx, ("op", #Text("30revoke_collection_approval")));
              Vec.add(trxtop, ("ts", #Nat(Int.abs(environment.get_time()))));
              Vec.add(trx, ("from", environment.icrc7.accountToValue({owner = environment.canister(); subaccount = null})));
              Vec.add(trx, ("spender", environment.icrc7.accountToValue(thisItem)));
              Vec.add(trx, ("memo", #Blob(memo)));
              

              let txMap = #Map(Vec.toArray(trx));
              let txTopMap = #Map(Vec.toArray(trxtop));
              let preNotification = {
                  spender = thisItem;
                  from = {owner = environment.canister(); subaccount = null};
                  created_at_time = ?Nat64.fromNat(Int.abs(environment.get_time()));
                  memo = ?memo;
                };

                
              //implment ledger;
              
              let transaction_id = switch(environment.icrc7.get_environment().add_ledger_transaction){
                case(null){
                  //use local ledger. This will not scale
                  let final = switch(insert_map(?txTopMap, "tx", txMap)){
                    case(#ok(val)) val;
                    case(#err(err)){
                      
                      continue proc;
                    };
                  };
                  Vec.add<Value>(environment.icrc7.get_state().ledger, final);
                  Vec.size(environment.icrc7.get_state().ledger) - 1;
                };
                case(?val) val(txMap, ?txTopMap);
              };

              for(thisEvent in Vec.vals(collection_revoked_listeners)){
                thisEvent.1(preNotification, transaction_id);
              };
            };
          };
          case(?token_id){
            let #ok(owner) = environment.icrc7.get_token_owner_canonical(token_id) else continue clean;
            let result =  revoke_approvals(thisItem.0.0, ?thisItem.0.1, thisItem.1.from_subaccount, ?owner);
            let memo = Text.encodeUtf8("icrc30_system_clean");
            label proc for(thisItem in result.vals()){
              let trx = Vec.new<(Text, Value)>();
              let trxtop = Vec.new<(Text, Value)>();
              Vec.add(trx, ("op", #Text("30revoke_token_approval")));
              Vec.add(trxtop, ("ts", #Nat(Int.abs(environment.get_time()))));
              Vec.add(trx, ("tknid", #Nat(token_id)));
              Vec.add(trx, ("from", environment.icrc7.accountToValue({owner = environment.canister(); subaccount = null})));
              Vec.add(trx, ("spender", environment.icrc7.accountToValue(thisItem)));
              Vec.add(trx, ("memo", #Blob(memo)));

              let txMap = #Map(Vec.toArray(trx));
              let txTopMap = #Map(Vec.toArray(trxtop));
              let preNotification = {
                spender = thisItem;
                token_id = token_id;
                from = {owner = environment.canister(); subaccount = null};
                created_at_time = ?Nat64.fromNat(Int.abs(environment.get_time()));
                memo = ?memo;
              };

              //implment ledger;
              let transaction_id = switch(environment.icrc7.get_environment().add_ledger_transaction){
                case(null){
                  //use local ledger. This will not scale
                  let final = switch(insert_map(?txTopMap, "tx", txMap)){
                    case(#ok(val)) val;
                    case(#err(err)){
                      continue proc;
                    };
                  };
                  Vec.add<Value>(environment.icrc7.get_state().ledger, final);
                  Vec.size(environment.icrc7.get_state().ledger) - 1;
                };
                case(?val) val(txMap, ?txTopMap);
              };

              for(thisEvent in Vec.vals(token_revoked_listeners)){
                thisEvent.1(preNotification, transaction_id);
              };

            };


          };
        };

        if(Map.size(state.token_approvals) <= remaining) break clean;
      };
    
    };

    


    // events

    type Listener<T> = (Text, T);

    /// Generic function to register a listener.
    ///
    /// Parameters:
    ///     namespace: Text - The namespace identifying the listener.
    ///     remote_func: T - A callback function to be invoked.
    ///     listeners: Vec<Listener<T>> - The list of listeners.
    public func register_listener<T>(namespace: Text, remote_func: T, listeners: Vec.Vector<Listener<T>>) {
      let listener: Listener<T> = (namespace, remote_func);
      switch(Vec.indexOf<Listener<T>>(listener, listeners, func(a: Listener<T>, b: Listener<T>) : Bool {
        Text.equal(a.0, b.0);
      })){
        case(?index){
          Vec.put<Listener<T>>(listeners, index, listener);
        };
        case(null){
          Vec.add<Listener<T>>(listeners, listener);
        };
      };
    };



    /// Registers a listener for when a token is approved.
    ///
    /// Parameters:
    ///      namespace: Text - The namespace identifying the listener.
    ///      remote_func: TokenApprovedListener - A callback function to be invoked on token approval.
    public func register_token_approved_listener(namespace: Text, remote_func : TokenApprovedListener){
      register_listener<TokenApprovedListener>(namespace, remote_func, token_approved_listeners);
    };

    /// Registers a listener for when a collection is approved.
    ///
    /// Parameters:
    ///      namespace: Text - The namespace identifying the listener.
    ///      remote_func: CollectionApprovedListener - A callback function to be invoked on collection approval.
    public func register_collection_approved_listener(namespace: Text, remote_func : CollectionApprovedListener){
      register_listener<CollectionApprovedListener>(namespace, remote_func, collection_approved_listeners);
    };

    /// Registers a listener for when a token approval is revoked.
    ///
    /// Parameters:
    ///      namespace: Text - The namespace identifying the listener.
    ///      remote_func: TokenApprovalRevokedListener - A callback function to be invoked on token approval revokation.
    public func register_token_revoked_listener(namespace: Text, remote_func : TokenApprovalRevokedListener){
      register_listener<TokenApprovalRevokedListener>(namespace, remote_func, token_revoked_listeners);
      
    };

    /// Registers a listener for when a collection is revoked.
    ///
    /// Parameters:
    ///      namespace: Text - The namespace identifying the listener.
    ///      remote_func: CollectionApprovalRevokedListener - A callback function to be invoked on collection approval.
    public func register_collection_revoked_listener(namespace: Text, remote_func : CollectionApprovalRevokedListener){
      register_listener<CollectionApprovalRevokedListener>(namespace, remote_func, collection_revoked_listeners);
    };

    /// Registers a listener for when a transfer from completes. Note. It is likely that a notification will be sent from Transfer as well.
    ///
    /// Parameters:
    ///      namespace: Text - The namespace identifying the listener.
    ///      remote_func: TransferFromListener - A callback function to be invoked on transfer from.
    public func register_transfer_from_listener(namespace: Text, remote_func : TransferFromListener){
      register_listener<TransferFromListener>(namespace, remote_func, transfer_from_listeners);
    };

    

    //ledger mangement

    /// Updates ledger information such as approval limitations with the provided request.
    /// - Parameters:
    ///     - request: `[UpdateLedgerInfoRequest]` - A list of requests containing the updates to be applied to the ledger.
    /// - Returns: `[Bool]` - An array of booleans indicating the success of each update request.
    public func update_ledger_info(request: [UpdateLedgerInfoRequest]) : [Bool]{
      
      //todo: Security at this layer?

      let results = Vec.new<Bool>();
      for(thisItem in request.vals()){
        switch(thisItem){
          
          case(#MaxApprovalsPerTokenOrColletion(val)){state.ledger_info.max_approvals_per_token_or_collection := val};
          case(#MaxRevokeApprovals(val)){state.ledger_info.max_revoke_approvals := val};
          case(#MaxApprovals(val)){state.ledger_info.max_approvals := val};
          case(#SettleToApprovals(val)){state.ledger_info.settle_to_approvals := val};
          case(#CollectionApprovalRequiresToken(val)){state.ledger_info.collection_approval_requires_token := val};
        };
        Vec.add(results, true);
      };
      return Vec.toArray(results);
    };

    //Update functions
  
    /// Revokes collection approval for the current caller based on provided arguments.
    /// - Parameters:
    ///     - caller: `Principal` - The principal of the user initiating the revoke action.
    ///     - revokeArgs: `RevokeCollectionArgs` - The arguments specifying the revoke action details.
    /// - Returns: `[RevokeCollectionResponseItem]` - A list of response items for each revoke action taken.
    private func revoke_collection_approval(caller : Principal, revokeArgs : RevokeCollectionArgs) : [RevokeCollectionResponseItem] {
      let result = revoke_approvals(null, revokeArgs.spender, revokeArgs.from_subaccount, ?{owner = caller; subaccount = revokeArgs.from_subaccount});

      let list = Vec.new<RevokeCollectionResponseItem>();

      let ?(memo) = testMemo(revokeArgs.memo) else return [{revoke_result = #Err(#GenericError({message="invalid memo. must be less than " # debug_show(environment.icrc7.get_ledger_info().max_memo_size) # " bits"; error_code=45})); spender = null}];

      label proc for(thisItem in result.vals()){
        let trx = Vec.new<(Text, Value)>();
        let trxtop = Vec.new<(Text, Value)>();
        Vec.add(trx, ("op", #Text("30revoke_collection_approval")));
        Vec.add(trxtop, ("ts", #Nat(Int.abs(environment.get_time()))));
        Vec.add(trx, ("from", environment.icrc7.accountToValue({owner = caller; subaccount = revokeArgs.from_subaccount})));
        Vec.add(trx, ("spender", environment.icrc7.accountToValue(thisItem)));
        switch(memo){
          case(null){};
          case(?val){
            Vec.add(trx, ("memo", #Blob(val)));
          };
        };

        switch(revokeArgs.created_at_time){
          case(null){};
          case(?val){
            Vec.add(trx, ("ts", #Nat(Nat64.toNat(val))));
          };
        };

        let txMap = #Map(Vec.toArray(trx));
        let txTopMap = #Map(Vec.toArray(trxtop));
        let preNotification = {
            spender = thisItem;
            from = {owner = caller; subaccount = revokeArgs.from_subaccount};
            created_at_time = revokeArgs.created_at_time;
            memo = revokeArgs.memo;
          };

        let(finaltx, finaltxtop, notification) : (Value, ?Value, RevokeCollectionNotification) = switch(environment.can_revoke_collection_approval){
          case(null){
            (txMap, ?txTopMap, preNotification);
          };
          case(?remote_func){
            switch(remote_func(txMap, ?txTopMap, preNotification)){
              case(#ok(val)) val;
              case(#err(tx)){
                Vec.add(list, {
                  spender = ?thisItem;
                  revoke_result = #Err(#GenericError({error_code = 394; message = tx}));
                });
                continue proc;
              };
            };
          };
        };

         //implment ledger;
        let transaction_id = switch(environment.icrc7.get_environment().add_ledger_transaction){
          case(null){
            //use local ledger. This will not scale
            let final = switch(insert_map(finaltxtop, "tx", finaltx)){
              case(#ok(val)) val;
              case(#err(err)){
                Vec.add(list, {
                  spender = ?thisItem;
                  revoke_result = #Err(#GenericError({error_code = 3849; message = err}));
                });
                continue proc;
              };
            };
            Vec.add<Value>(environment.icrc7.get_state().ledger, final);
            Vec.size(environment.icrc7.get_state().ledger) - 1;
          };
          case(?val) val(finaltx, finaltxtop);
        };

        for(thisEvent in Vec.vals(collection_revoked_listeners)){
          thisEvent.1(notification, transaction_id);
        };

        Vec.add<RevokeCollectionResponseItem>(list, {
          spender = ?thisItem;
          revoke_result = #Ok(transaction_id);
        })
      };

      return Vec.toArray(list);
    };

    /// Revokes collection approvals for the current caller based on provided arguments.
    /// - Parameters:
    ///     - caller: `Principal` - The principal of the user initiating the revoke action.
    ///     - revokeArgs: `RevokeCollectionArgs` - The arguments specifying the revoke action details.
    /// - Returns: `Result<RevokeCollectionResponse, Text>` - A result containing either the revoke collection response or an error message.
    public func revoke_collection_approvals(caller : Principal, revokeArgs: RevokeCollectionArgs) : Result.Result<RevokeCollectionResponse, Text> {

      //validate

      //test that the memo is not too large
      let ?(memo) = testMemo(revokeArgs.memo) else return #err("invalid memo. must be less than " # debug_show(environment.icrc7.get_ledger_info().max_memo_size) # " bits");

      //make sure the approval is not too old or too far in the future
      let created_at_time = switch(testCreatedAt(revokeArgs.created_at_time, environment)){
        case(#ok(val)) val;
        case(#Err(#TooOld)) return #ok(#Err(#TooOld));
        case(#Err(#InTheFuture(val))) return  #ok(#Err(#CreatedInFuture({ledger_time =Nat64.fromNat(Int.abs(environment.get_time()))})));
      };
        
      let list = Vec.new<RevokeCollectionResponseItem>();
  
      let result = revoke_collection_approval(caller, revokeArgs);

      for(thisItem in result.vals()){
        Vec.add<RevokeCollectionResponseItem>(list, thisItem)
      };
    

      #ok(#Ok(Vec.toArray(list)));
    };

    /// Revokes a single token transfer approval
    /// - Parameters:
    ///     - caller: `Principal` - The principal of the user initiating the revoke action.
    ///     - token_id: `?Nat` - An optional token ID. If `null`, all collections associated with the spender are considered.
    ///     - revokeArgs: `RevokeCollectionArgs` - The arguments specifying the revoke action details.
    /// - Returns: `[Account]` - A list of spenders who were affected by the revocation.
    ///
    /// warning: Does not provide top level validation. Use revoke_token_approvals to validadate top level paramaters
    private func revoke_token_approval(caller : Principal, token_id: Nat, revokeArgs : RevokeTokensArgs) : [RevokeTokensResponseItem] {

      let #ok(owner) = environment.icrc7.get_token_owner_canonical(token_id) else return [{token_id= token_id; revoke_result = #Err(#GenericError({
        error_code = 3;
        message = "owner not set"
      })); spender=null}];

      if(not account_eq( {owner = caller; subaccount = revokeArgs.from_subaccount}, owner)) return [{token_id= token_id; revoke_result = #Err(#Unauthorized); spender = null}]; //can only revoke your own tokens;

      let ?(memo) = testMemo(revokeArgs.memo) else return [{token_id= token_id; revoke_result = #Err(#GenericError({
        error_code = 56;
        message = "illegal memo"
      })); spender=null}];

      let result = revoke_approvals(?token_id, revokeArgs.spender, revokeArgs.from_subaccount, ?owner);

      let list = Vec.new<RevokeTokensResponseItem>();

      label proc for(thisItem in result.vals()){
        let trx = Vec.new<(Text, Value)>();
        let trxtop = Vec.new<(Text, Value)>();

        Vec.add(trx, ("tknid", #Nat(token_id)));
        Vec.add(trx, ("op", #Text("30revoke_token_approval")));
        Vec.add(trxtop, ("ts", #Nat(Int.abs(environment.get_time()))));
        Vec.add(trx, ("from", environment.icrc7.accountToValue({owner = caller; subaccount = revokeArgs.from_subaccount})));
        Vec.add(trx, ("spender", environment.icrc7.accountToValue(thisItem)));

        switch(memo){
          case(null){};
          case(?val){
            Vec.add(trx, ("memo", #Blob(val)));
          };
        };

        switch(revokeArgs.created_at_time){
          case(null){};
          case(?val){
            Vec.add(trx, ("ts", #Nat(Nat64.toNat(val))));
          };
        };

        let txMap = #Map(Vec.toArray(trx));
        let txTopMap = #Map(Vec.toArray(trxtop));
        let preNotification = {
            spender = thisItem;
            token_id = token_id;
            from = {owner = caller; subaccount = revokeArgs.from_subaccount};
            created_at_time = revokeArgs.created_at_time;
            memo = revokeArgs.memo;
          };

        let(finaltx, finaltxtop, notification) : (Value, ?Value, RevokeTokenNotification) = switch(environment.can_revoke_token_approval){
          case(null){
            (txMap, ?txTopMap, preNotification);
          };
          case(?remote_func){
            switch(remote_func(txMap, ?txTopMap, preNotification)){
              case(#ok(val)) val;
              case(#err(tx)){
                Vec.add(list, {
                  token_id = token_id;
                  spender = ?thisItem;
                  revoke_result = #Err(#GenericError({error_code = 394; message = tx}));
                });
                continue proc;
              };
            };
          };
        };

         //implement ledger;
        let transaction_id = switch(environment.icrc7.get_environment().add_ledger_transaction){
          case(null){
            //use local ledger. This will not scale
            let final = switch(insert_map(finaltxtop, "tx", finaltx)){
              case(#ok(val)) val;
              case(#err(err)){
                Vec.add(list, {
                  token_id = token_id;
                  spender = ?thisItem;
                  revoke_result = #Err(#GenericError({error_code = 394; message = err}));
                });
                continue proc;
              };
            };
            Vec.add<Value>(environment.icrc7.get_state().ledger, final);
            Vec.size(environment.icrc7.get_state().ledger) - 1;
          };
          case(?val) val(finaltx, finaltxtop);
        };

        for(thisEvent in Vec.vals(token_revoked_listeners)){
          thisEvent.1(notification, transaction_id);
        };

        Vec.add<RevokeTokensResponseItem>(list, {
          token_id = token_id;
          spender = ?thisItem;
          revoke_result = #Ok(transaction_id);
        })
      };

      return Vec.toArray(list);
    };

    /// Revokes approvals and removes them from records and indexes, for a specified token ID and spender.
    /// - Parameters:
    ///     - token_id: `?Nat` - An optional token ID. If `null`, all collections associated with the spender are considered.
    ///     - spender: `?Account` - An optional spender account. If `null`, all spenders are considered for the specified token.
    ///     - from_subaccount: `?Blob` - An optional subaccount from which revocation is initiated.
    ///     - former_owner: `?Account` - The owner account before revocation.
    /// - Returns: `[Account]` - A list of spenders who were affected by the revocation.
    private func revoke_approvals(token_id: ?Nat, spender: ?Account, from_subaccount: ?Blob, former_owner: ?Account) :  [Account] {

      let spenders = Vec.new<Account>();

      //clean up owner index

      switch(Map.get(state.indexes.token_to_approval_account, nullnathash, token_id)){
        case(?idx){
          switch(spender){
            case(null){
              //remove them all
             
              label proc for(thisItem in Set.keys<Account>(idx)){
                switch(from_subaccount){
                  case(?val){
                    let ?rec = Map.get<(?Nat,Account), ApprovalInfo>(state.token_approvals, apphash, (token_id, thisItem)) else return D.trap("unreachable");
                    if(rec.from_subaccount != from_subaccount) continue proc;
                    ignore Set.remove<Account>(idx, ahash, thisItem);
                  };
                  case(null){};
                };
                Vec.add(spenders, thisItem);

                ignore Map.remove<(?Nat,Account),ApprovalInfo>(state.token_approvals, apphash, (token_id, thisItem));

                switch(former_owner){
                  case(null){};
                  case(?former_owner){
                    switch(Map.get(state.indexes.owner_to_approval_account, ahash, former_owner)){
                      case(null){}; //should be unreachable
                      case(?set){
                        ignore Set.remove<(?Nat, Account)>(set, apphash, (token_id, thisItem));
                        if(Set.size(set) == 0){
                          ignore Map.remove(state.indexes.owner_to_approval_account, ahash, former_owner);
                        };
                      };
                    };
                  };
                };
                //remove the index
              };
              if(from_subaccount == null or Set.size(idx) == 0){
                ignore Map.remove<?Nat, Set.Set<Account>>(state.indexes.token_to_approval_account, nullnathash, token_id);
              };
            };
            case(?val){
              switch(from_subaccount){
                case(?from_subaccount){
                  let ?rec = Map.get<(?Nat,Account), ApprovalInfo>(state.token_approvals, apphash, (token_id, val)) else return [];
                  if(rec.from_subaccount != ?from_subaccount) return [];
                };
                case(null){};
              };
              ignore Map.remove<(?Nat,Account), ApprovalInfo>(state.token_approvals, apphash, (token_id, val));
              ignore Set.remove<Account>(idx, ahash, val);
              if(Set.size(idx) == 0){
                ignore Map.remove(state.indexes.token_to_approval_account, nullnathash, token_id);
              };

              //clean owner to token spender index
              switch(former_owner){
                case(null){};
                case(?former_owner){
                  switch(Map.get(state.indexes.owner_to_approval_account, ahash, former_owner)){
                    case(null){}; //should be unreachable
                    case(?set){
                      ignore Set.remove<(?Nat, Account)>(set, apphash, (token_id, val));
                      if(Set.size(set) == 0){
                        ignore Map.remove(state.indexes.owner_to_approval_account, ahash, former_owner);
                      };
                    };
                  };
                };
              };
              Vec.add(spenders, val);
            }
          };
        };
        case(null){
          return [];
        }
      };

      return Vec.toArray(spenders);
    };

    /// Event callback that is triggered post token transfer, used to revoke any approvals upon ownership change.
    /// - Parameters:
    ///     - token_id: `Nat` - The ID of the token that was transferred.
    ///     - from: `?Account` - The previous owner's account.
    ///     - to: `Account` - The new owner's account.
    ///     - trx_id: `Nat` - The unique identifier for the transfer transaction.
    private func token_transferred(transfer: TransferNotification, trx_id: Nat) : (){
      debug if(debug_channel.announce) D.print("token_transfered was called " # debug_show((transfer.token_id, transfer.from, transfer.to, trx_id)));
      //clear all approvals for this token
      //note: we do not have to log these revokes to the transaction log becasue ICRC30 defines that all approvals are revoked when a token is transfered.
      ignore revoke_approvals(?transfer.token_id, null, null, ?transfer.from);
    };

    //registers the private token_transfered event with the ICRC7 component so that approvals can be cleared when a token is transfered.
    environment.icrc7.register_token_transferred_listener("icrc30", token_transferred);

    /// Revokes a single token transfer approval
    /// - Parameters:
    ///     - caller: `Principal` - The principal of the user initiating the revoke action.
    ///     - revokeArgs: `RevokeCollectionArgs` - The arguments specifying the revoke action details.
    /// - Returns: `[Account]` - A list of spenders who were affected by the revocation.
    public func revoke_token_approvals(caller : Principal, revokeArgs: RevokeTokensArgs) : Result.Result<RevokeTokensResponse, Text> {

      //validate

      //test that the memo is not too large
      let ?(memo) = testMemo(revokeArgs.memo) else return #err("invalid memo. must be less than " # debug_show(environment.icrc7.get_ledger_info().max_memo_size) # " bits");

      //make sure the approval is not too old or too far in the future
      let created_at_time = switch(testCreatedAt(revokeArgs.created_at_time, environment)){
        case(#ok(val)) val;
        case(#Err(#TooOld)) return #ok(#Err(#TooOld));
        case(#Err(#InTheFuture(val))) return  #ok(#Err(#CreatedInFuture({ledger_time = Nat64.fromNat(Int.abs(environment.get_time()))} )));
      };

      //check that the batch isn't too big
        let safe_batch_size = state.ledger_info.max_revoke_approvals;

        if(revokeArgs.token_ids.size() > safe_batch_size){
          return #err("too many approvals revoked at one time");
          /* return [{
            token_id = revokeArgs.token_ids[0]; 
            spender = revokeArgs.spender; 
            revoke_result =#Err(#GenericError({error_code = 15; message = "too many approvals revoked at one time"}))
            }]; */
        };

      if(revokeArgs.token_ids.size() == 0) return #err("empty token_ids");

      if(hasDupes(revokeArgs.token_ids)) return #err("duplicate tokesn in token_ids");
      
      let list = Vec.new<RevokeTokensResponseItem>();
      for(x in revokeArgs.token_ids.vals()) { 
          debug if(debug_channel.revoke) D.print("revoking approval for token" # Nat.toText(x));
          let result = revoke_token_approval(caller, x, revokeArgs);

          for(thisItem in result.vals()){
            Vec.add<RevokeTokensResponseItem>(list, thisItem)
          };
      };

      #ok(#Ok(Vec.toArray(list)));
    };

    /// Approves a collection by setting a universal spender for all tokens within a collection.
    /// - Parameters:
    ///     - caller: `Principal` - The principal of the user initiating the approval operation.
    ///     - approval: `ApprovalInfo` - Approval settings including spender and optional expiry.
    /// - Returns: `Result<ApprovalResult, Text>` - A result that includes approval transaction ID or an error text.
    public func approve_collection(caller: Principal, approval: ApprovalInfo) : Result.Result<ApprovalResult, Text> {

      //test that the memo is not too large
      let ?(memo) = testMemo(approval.memo) else return #err("invalid memo. must be less than " # debug_show(environment.icrc7.get_ledger_info().max_memo_size) # " bits");

      //test that the expires is not in the past
      let ?(expires_at) = testExpiresAt(approval.expires_at) else return #err("already expired");


      //make sure the approval is not too old or too far in the future
      let created_at_time = switch(testCreatedAt(approval.created_at_time, environment)){
        case(#ok(val)) val;
        case(#Err(#TooOld)) return #ok(#Err(#TooOld));
        case(#Err(#InTheFuture(val))) return  #ok(#Err(#CreatedInFuture({ledger_time = Nat64.fromNat(Int.abs(environment.get_time()))})));
      };

      //make sure the account doesn't have too many approvals

      let current_approvals = switch(Map.get(state.indexes.owner_to_approval_account, ahash, {owner = caller; subaccount = approval.from_subaccount})){
        case(?val){
          Set.size(val);
        };
        case(null) 0;
      };

      debug if(debug_channel.approve) D.print("number of approvals" # debug_show(current_approvals));

      if(current_approvals >= state.ledger_info.max_approvals_per_token_or_collection){
        return #err("Too many approvals from account" # debug_show({owner = caller; subaccount = approval.from_subaccount}));
      };

      let result : (?Nat, ApprovalResult) = approve_transfer(environment, caller, null, approval);

      debug if(debug_channel.approve) D.print("Finished putting approval " # debug_show(result, approval));
      
      switch(result.0, result.1){
        case(?val, _) {// should be unreachable;
          return #err("unreachable null token"); 
        }; 
        case(null, #Ok(val)) return #ok(#Ok(val));
        case(null, #Err(err)) return #ok(#Err(err));
      };
    };

    private func insert_map(top: ?Value, key: Text, val: Value): Result.Result<Value, Text> {
      let foundTop = switch(top){
        case(?val) val;
        case(null) #Map([]);
      };
      switch(foundTop){
        case(#Map(a_map)){
          let vecMap = Vec.fromArray<(Text, Value)>(a_map);
          Vec.add<(Text, Value)>(vecMap, (key, val));
          return #ok(#Map(Vec.toArray(vecMap)));
        };
        case(_) return #err("bad map");
      };
    };


    /// approve the transfer of a token by a spender
    private func approve_transfer(environment: Environment, caller: Principal, token_id: ?Nat, approval: ApprovalInfo) : (?Nat, ApprovalResult) {
      
      if(approval.spender.owner == caller) return (token_id, #Err(#Unauthorized)); //can't make yourself a spender;

      let trx = Vec.new<(Text, Value)>();
      let trxtop = Vec.new<(Text, Value)>();

      //test that the memo is not too large
      switch(testMemo(approval.memo)){
        case(?null){};
        case(??val){
          Vec.add(trx,("memo", #Blob(val)));
        };
        case(_){}; //unreachable if called from approve_transfers
      };

      //test that the expires is not in the past
      switch(testExpiresAt(approval.expires_at)){
        case(?null){};
        case(??val){
          Vec.add(trx,("expires_at", #Nat(Nat64.toNat(val))));
        };
        case(_){}; //unreachable if called from approve_transfers
      };

      //test that the expires is not in the past
      switch(approval.created_at_time){
        case(null){};
        case(?val){
          Vec.add(trx,("ts", #Nat(Nat64.toNat(val))));
        };
      };

      //test that this caller owns the token in the specified subaccount;
      switch(token_id){
        case(null){
          //do collection checks
          
          if(state.ledger_info.collection_approval_requires_token == true){
            switch(Map.get<Account, Set.Set<Nat>>(environment.icrc7.get_state().indexes.owner_to_nfts, ahash, {owner = caller; subaccount = approval.from_subaccount})){
              case(null) return (token_id ,#Err(#Unauthorized));//user owns no nfts
              case(_){};
            };
          };
          Vec.add(trx,("op", #Text("30approve_collection")));
        };
        case(?token_id){
          
          let ?nft = Map.get<Nat,NFT>(environment.icrc7.get_state().nfts, Map.nhash, token_id) else return (?token_id, #Err(#NonExistingTokenId));

          let owner = switch(environment.icrc7.get_token_owner_canonical(token_id)){
            case(#err(e)) return (?token_id, #Err(#GenericError(e)));
            case(#ok(val)) val;
          };

          if(owner.owner != caller) return (?token_id, #Err(#Unauthorized)); //only the owner can approve;

          if(owner.subaccount != approval.from_subaccount) return (?token_id, #Err(#Unauthorized)); //from_subaccount must match owner;

          Vec.add(trx,("tid", #Nat(token_id)));
          Vec.add(trx,("op", #Text("30approve_tokens")));
        };
      };

      Vec.add(trxtop,("ts", #Nat(Int.abs(environment.get_time()))));
     
      
      
      Vec.add(trx,("from", environment.icrc7.accountToValue({owner = caller; subaccount = approval.from_subaccount})));

      Vec.add(trx,("spender", environment.icrc7.accountToValue(approval.spender)));

      //check for duplicate
      let trxhash = Blob.fromArray(RepIndy.hash_val(#Map(Vec.toArray(trx))));

      switch(environment.icrc7.find_dupe(trxhash)){
        case(?found){
          return (token_id, #Err(#Duplicate({duplicate_of = found})));
        };
        case(null){};
      };

      let txMap = #Map(Vec.toArray(trx));
      let txTopMap = #Map(Vec.toArray(trxtop));

      let(finaltx, finaltxtop, tokenNotification, collectionNotification) : (Value, ?Value, ?TokenApprovalNotification, ?CollectionApprovalNotification)= switch(token_id){
        case(null){
          let preNotification = {
              spender = approval.spender;
              from = {owner = caller; subaccount = approval.from_subaccount};
              created_at_time = approval.created_at_time;
              memo = approval.memo;
              expires_at = approval.expires_at;
            };

          switch(environment.can_approve_collection){
            case(null){
              (txMap, ?txTopMap, null, ?preNotification);
            };
            case(?remote_func){
              switch(remote_func(txMap, ?txTopMap, preNotification)){
                case(#ok(val)) (val.0, val.1, null, ?val.2);
                case(#err(tx)){
                  return(null, #Err(#GenericError({error_code = 394; message = tx})));
                };
              };
            };
          };
        };
        case(?token_id)
        {
          let preNotification = {
              spender = approval.spender;
              token_id = token_id;
              from = {owner = caller; subaccount = approval.from_subaccount};
              created_at_time = approval.created_at_time;
              memo = approval.memo;
              expires_at = approval.expires_at;
            };

          switch(environment.can_approve_token){
            case(null){
              (txMap, ?txTopMap, ?preNotification, null);
            };
            case(?remote_func){
              switch(remote_func(txMap, ?txTopMap, preNotification)){
                case(#ok(val)) (val.0, val.1, null, ?val.2);
                case(#err(tx)){
                  return(null, #Err(#GenericError({error_code = 394; message = tx})));
                };
              };
            };
          };
        };    
      };

      //todo: implment ledger;
      let transaction_id = switch(environment.icrc7.get_environment().add_ledger_transaction){
        case(null){
            //use local ledger. This will not scale
            let final = switch(insert_map(finaltxtop, "tx", finaltx)){
              case(#ok(val)) val;
              case(#err(err)){
                return(token_id,  #Err(#GenericError({error_code = 3849; message = err})));
              };
            };
            Vec.add<Value>(environment.icrc7.get_state().ledger, final);
            Vec.size(environment.icrc7.get_state().ledger) - 1;
          };
          case(?val) val(finaltx, finaltxtop);
      };

      //find existing approval
      switch(Map.get<(?Nat,Account),ApprovalInfo>(state.token_approvals, apphash, (token_id,approval.spender))){
        case(null){};
        case(?val){
          //an approval already exists for this token/spender combination
          //we need to remove it and then re-add it to maintin the queueness of the map
          ignore Map.remove<(?Nat,Account),ApprovalInfo>(state.token_approvals, apphash, (token_id,approval.spender));
        };
      };

      debug if(debug_channel.approve) D.print("adding to token approvals " # debug_show(token_id, approval.spender));
      
      ignore Map.add<(?Nat,Account),ApprovalInfo>(state.token_approvals, apphash, (token_id, approval.spender), approval);

      //populate the index
      let existingIndex = switch(Map.get<?Nat, Set.Set<Account>>(state.indexes.token_to_approval_account, nullnathash, token_id)){
        case(null){
          debug if(debug_channel.approve) D.print("adding new index " # debug_show(token_id));
          let newIndex = Set.new<Account>();
          ignore Map.add<?Nat,Set.Set<Account>>(state.indexes.token_to_approval_account, nullnathash, token_id, newIndex);
          newIndex;
        };
        case(?val) val;
      };

      Set.add<Account>(existingIndex, ahash, approval.spender);
      

      //populate the index
      let existingIndex2 = switch(Map.get<Account, Set.Set<(?Nat, Account)>>(state.indexes.owner_to_approval_account, ahash, {owner = caller; subaccount = approval.from_subaccount})){
        case(null){
          debug if(debug_channel.approve) D.print("adding new index " # debug_show({owner = caller; subaccount = approval.from_subaccount}));
          let newIndex = Set.new<(?Nat, Account)>();
          ignore Map.add<Account,Set.Set<(?Nat, Account)>>(state.indexes.owner_to_approval_account, ahash, {owner = caller; subaccount = approval.from_subaccount}, newIndex);
          newIndex;
        };
        case(?val) val;
      };

      Set.add<(?Nat, Account)>(existingIndex2, apphash, (token_id, approval.spender));

      ignore Map.put<Blob, (Int,Nat)>(environment.icrc7.get_state().indexes.recent_transactions, Map.bhash, trxhash, (environment.get_time(), transaction_id));

      switch(token_id){
        case(null){
          let ?thisNotification = collectionNotification;
          for(thisEvent in Vec.vals(collection_approved_listeners)){
            thisEvent.1(thisNotification, transaction_id);
          };
        };
        case(?token_id)
        {
          let ?thisNotification = tokenNotification;
          for(thisEvent in Vec.vals(token_approved_listeners)){
            thisEvent.1(thisNotification, transaction_id);
        };
        }      
      };

      environment.icrc7.cleanUpRecents();
      cleanUpApprovalsRoutine();

      debug if(debug_channel.approve) D.print("Finished putting approval " # debug_show(token_id, approval));

      return(token_id, #Ok(transaction_id));
    };

    /// Detects duplicates in a Nat Array
    private func hasDupes(items : [Nat]) : Bool {
      let aSet = Set.fromIter<Nat>(items.vals(), Map.nhash);
      return Set.size(aSet) != items.size();
    };

    
    private func transfer_token(caller: Principal, token_id: Nat, transferFromArgs: TransferFromArgs) : TransferFromResponseItem {

        //make sure that either the caller is the owner or an approved spender
        let ?nft = Map.get<Nat,NFT>(environment.icrc7.get_state().nfts, Map.nhash, token_id) else return {token_id = token_id; transfer_result = #Err(#NonExistingTokenId)};

        let owner = switch(environment.icrc7.get_token_owner_canonical(token_id)){
          case(#err(e)) return { token_id = token_id; transfer_result = #Err(#GenericError(e))};
          case(#ok(val)) val;
        };

        var spender : ?Account = null;
        let potential_spender = {
            owner = caller;
            subaccount = transferFromArgs.spender_subaccount;
          };

        debug if(debug_channel.approve) D.print("checking owner and caller" # debug_show(owner, caller));

        if(owner.owner == caller){
          return {token_id = token_id; transfer_result= #Err(#Unauthorized)}; //can't spend your own token;
        };

        switch(Map.get<(?Nat,Account),ApprovalInfo>(state.token_approvals, apphash, (null, potential_spender))){
          case(null){};
          case(?val){
            switch(val.expires_at){
              case(?expires_at){
                if(Int.abs(environment.get_time()) < Nat64.toNat(expires_at)){
                  spender := ?potential_spender;
                };
              };
              case(null){
                spender := ?potential_spender;
              };
            };
          };
        };

        if(spender == null){
          switch(Map.get<(?Nat,Account),ApprovalInfo>(state.token_approvals, apphash, (?token_id, potential_spender))){
            case(null){};
            case(?val){
              switch(val.expires_at){
                case(?expires_at){
                  if(Int.abs(environment.get_time()) < Nat64.toNat(expires_at)){
                    spender := ?potential_spender;
                  };
                };
                case(null){
                  spender := ?potential_spender;
                };
              };
            };
          };
        };

        debug if(debug_channel.approve) D.print("checking spender" # debug_show(potential_spender, spender));


        if(spender == null){
          return {token_id = token_id; transfer_result= #Err(#Unauthorized)}; //only the spender can spend;
        };
      

        if(owner.subaccount != transferFromArgs.from.subaccount) return { token_id = token_id;transfer_result =  #Err(#Unauthorized)}; //from_subaccount must match owner;

        let trx = Vec.new<(Text, Value)>();
        let trxtop = Vec.new<(Text, Value)>();

        switch(transferFromArgs.memo){
          case(null){};
          case(?val){
            Vec.add(trx,("memo", #Blob(val)));
          };
        };

        switch(transferFromArgs.created_at_time){
          case(null){};
          case(?val){
            Vec.add(trx,("ts", #Nat(Nat64.toNat(val))));
          };
        };

        Vec.add(trx,("tid", #Nat(token_id)));
        Vec.add(trx,("ts", #Nat(Int.abs(environment.get_time()))));
        Vec.add(trx,("op", #Text("30xfer_from")));
        
        Vec.add(trx,("from", environment.icrc7.accountToValue({owner = transferFromArgs.from.owner; subaccount = transferFromArgs.from.subaccount})));
        Vec.add(trx,("to", environment.icrc7.accountToValue({owner = transferFromArgs.to.owner; subaccount = transferFromArgs.to.subaccount})));
        switch(spender){
          case(?val){
            Vec.add(trx,("spender", environment.icrc7.accountToValue(val)));
          };
          case(null){};//unreachable
        };

        let txMap = #Map(Vec.toArray(trx));
        let txTopMap = #Map(Vec.toArray(trxtop));
        let preNotification = {
          spender = switch(spender){
            case(?val)val;
            case(null){{owner = environment.canister(); subaccount = null;}}; //unreachable;
          };
          token_id = token_id;
          from = transferFromArgs.from;
          to = transferFromArgs.to;
          created_at_time = transferFromArgs.created_at_time;
          memo = transferFromArgs.memo;
        };

        let(finaltx, finaltxtop, notification) : (Value, ?Value, TransferFromNotification) = switch(environment.can_transfer_from){
          case(null){
            (txMap, ?txTopMap, preNotification);
          };
          case(?remote_func){
            switch(remote_func(txMap, ?txTopMap, preNotification)){
              case(#ok(val)) val;
              case(#err(tx)){
                
                return {
                  token_id = token_id;
                  transfer_result = #Err(#GenericError({error_code = 394; message = tx}));
                };
              };
            };
          };
        };

        let transaction_result =  environment.icrc7.finalize_token_transfer(caller, {transferFromArgs with
        subaccount = transferFromArgs.from.subaccount} : ICRC7.TransferArgs, trx, trxtop, token_id);

        switch(transaction_result.transfer_result){
          case(#Ok(transaction_id)){
            for(thisEvent in Vec.vals(transfer_from_listeners)){
              thisEvent.1(notification, transaction_id);
            };
          };
          case(_){};
        };
    
        return transaction_result;
    };

    /// Transfers tokens to a new owner as specified in the transferFromArgs.
    /// - Parameters:
    ///     - caller: `Principal` - The principal of the user initiating the transfer.
    ///     - transferFromArgs: `TransferFromArgs` - The arguments specifying the transfer details.
    /// - Returns: `Result<TransferFromResponse, Text>` - The result of the transfer operation, containing either a successful response or an error text.
    ///
    /// Example:
    /// ```motoko
    /// let transferResult = myICRC30Instance.transfer_from(
    ///   caller,
    ///   {
    ///     from = { owner = ownerPrincipal; subaccount = null };
    ///     to = { owner = recipientPrincipal; subaccount = null };
    ///     token_ids = [789];
    ///     memo = ?Blob.fromArray(Text.toArray("TransferMemo"));
    ///     created_at_time = ?1_615_448_461_000_000_000;
    ///     spender_subaccount = null;
    ///   }
    /// );
    /// ```
    public func transfer_from(caller: Principal, transferFromArgs: TransferFromArgs) : Result.Result<TransferFromResponse, Text> {

      //check that the batch isn't too big
      let safe_batch_size = environment.icrc7.get_ledger_info().max_update_batch_size;

      if(transferFromArgs.token_ids.size() == 0){
        return #err("no tokens provided");
        //return [(transferFromArgstoken_ids[0], #Err(#GenericError({error_code = 12; message = "too many tokens transfered at one time"})))];
      };

      if(hasDupes(transferFromArgs.token_ids)){
        return #err("duplicate tokens");
        //return [(transferFromArgstoken_ids[0], #Err(#GenericError({error_code = 12; message = "too many tokens transfered at one time"})))];
      };

      if(transferFromArgs.token_ids.size() > safe_batch_size){
        return #err("too many tokens transfered at one time");
        //return [(transferFromArgstoken_ids[0], #Err(#GenericError({error_code = 12; message = "too many tokens transfered at one time"})))];
      };

      //check to and from account not equal
      if(account_eq(transferFromArgs.to, transferFromArgs.from)){
        return #err("cannot transfer tokens to same account");
      };

      //test that the memo is not too large
      let ?(memo) = testMemo(transferFromArgs.memo) else return #err("invalid memo. must be less than " # debug_show(environment.icrc7.get_ledger_info().max_memo_size) # " bits");

      
      //make sure the approval is not too old or too far in the future
      let created_at_time = switch(testCreatedAt(transferFromArgs.created_at_time, environment)){
        case(#ok(val)) val;
        case(#Err(#TooOld)) return #ok(#Err(#TooOld));
        case(#Err(#InTheFuture(val))) return  #ok(#Err(#CreatedInFuture({ledger_time = Nat64.fromNat(Int.abs(environment.get_time()))})));
      };

      debug if(debug_channel.transfer) D.print("passed checks and calling token transfer");

      return #ok(#Ok(Array.map<Nat, TransferFromResponseItem>(transferFromArgs.token_ids,  func(x) : TransferFromResponseItem { 
          return transfer_token(caller, x, transferFromArgs);
        }
      )));
    };

    /// Retrieves statistics related to the ledger and approvals.
    /// - Returns: `Stats` - Statistics reflecting the state of the ledger and the number of approvals set by owners.
    public func get_stats() : Stats{
      return {
        ledger_info = {
          max_approvals_per_token_or_collection  = state.ledger_info.max_approvals_per_token_or_collection;
          max_revoke_approvals    = state.ledger_info.max_revoke_approvals;
        };
        token_approvals_count = Map.size(state.token_approvals);
        indexes = {
          token_to_approval_account_count = Map.size(state.indexes.token_to_approval_account);
          owner_to_approval_account_count = Map.size(state.indexes.owner_to_approval_account);
        };
      };
    };

  };

};