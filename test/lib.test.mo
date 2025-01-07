import ICRC37 "../src";
import Service "../src/service";
import ICRC7 "../../icrc7.mo/src";
import Principal "mo:base/Principal";
import CandyTypesLib "mo:candy_0_3_0/types";
import CandyConv  "mo:candy_0_3_0/conversion";
import Properties "mo:candy_0_3_0/properties";
import Array "mo:base/Array";
import Blob "mo:base/Blob";
import Int "mo:base/Int";
import Iter "mo:base/Iter";
import Text "mo:base/Text";
import Nat "mo:base/Nat";
import Nat64 "mo:base/Nat64";
import Map "mo:map9/Map";
import Set "mo:map9/Set";
import Opt "mo:base/Option";
import D "mo:base/Debug";
import Time "mo:base/Time";
import {test; testsys} "mo:test";
import Vec "mo:vector";
import ClassPlusLib "../../../../ICDevs/projects/ClassPlus/src/";

let testOwner = Principal.fromText("exoh6-2xmej-lux3z-phpkn-2i3sb-cvzfx-totbl-nzfcy-fxi7s-xiutq-mae");
let testOwnerAccount = {
  owner = testOwner;
  subaccount = null
};
let testCanister = Principal.fromText("p75el-ys2la-2xa6n-unek2-gtnwo-7zklx-25vdp-uepyz-qhdg7-pt2fi-bqe");

let spender1 : ICRC7.Account = {owner = Principal.fromText("2dzql-vc5j3-p5nyh-vidom-fhtyt-edvv6-bqewt-j63fn-ovwug-h67hb-yqe"); subaccount = ?Blob.fromArray([1,2])};
let spender2 : ICRC7.Account = {owner = Principal.fromText("32fn4-qqaaa-aaaak-ad65a-cai"); subaccount = ?Blob.fromArray([3,4])};
let spender3 : ICRC7.Account = {owner = Principal.fromText("zfcdd-tqaaa-aaaaq-aaaga-cai"); subaccount = ?Blob.fromArray([5,6])};
let spender4 : ICRC7.Account = {owner = Principal.fromText("x33ed-h457x-bsgyx-oqxqf-6pzwv-wkhzr-rm2j3-npodi-purzm-n66cg-gae"); subaccount = ?Blob.fromArray([7,8])};
let spender5 : ICRC7.Account = {owner = Principal.fromText("dtnbn-kyaaa-aaaak-aeigq-cai"); subaccount = ?Blob.fromArray([9,10])};

let baseCollection = {
  symbol = ?"anft";
  name = ?"A Test NFT";
  description = ?"A Descripton";
  logo = ?"http://example.com/test.png";
  supply_cap = ?100;
  allow_transfers = null;
  max_query_batch_size = ?102;
  max_update_batch_size = ?103;
  default_take_value = ?104;
  max_take_value = ?105;
  max_memo_size = ?512;
  permitted_drift = ?10; //temp until we can test by manipulatint time.now
  tx_window = null;
  burn_account = null;
  supported_standards = null;
  deployer = testOwner;
};

let base37Collection = {
  max_approvals_per_token_or_collection = ?101;
  max_revoke_approvals = ?106;
  max_approvals = ?500;
  settle_to_approvals = ?450;
  collection_approval_requires_token = ?true;
  deployer = testOwner;
};

let baseNFT : CandyTypesLib.CandyShared = #Class([
  {immutable=false; name="url"; value = #Text("https://example.com/1");}
]);

let baseNFTWithSubAccount : CandyTypesLib.CandyShared = #Class([
  {immutable=false; name="url"; value = #Text("https://example.com/1");}
]);

func get_canister() : Principal{
  return testCanister;
};

let init_time = Nat64.fromNat(Int.abs(Time.now())) : Nat64;
var test_time = init_time : Nat64;
let one_day = 86_400_000_000_000: Nat64;
let one_hour = one_day/24: Nat64;
let one_minute = one_hour/60: Nat64;
let one_second = one_minute/60: Nat64;

func get_time() : Int{
  return Nat64.toNat(test_time);
};

func get_time64() : Nat64{
  return test_time;
};

func set_time(x : Nat64) : Nat64{
  test_time += x;
  return test_time;
};






var icrc7_migration_state = ICRC7.initialState();

func get_icrc7_state(): ICRC7.CurrentState{
  let #v0_1_0(#data(icrc7_state_current)) = icrc7_migration_state; 
  icrc7_state_current;
}; 

func getEnvironment_ICRC7() : ICRC7.Environment{
  return base_environment_ICRC7;
};

let base_environment_ICRC7 = {

  log = null;
  add_ledger_transaction = null;
  can_mint = null;
  can_burn = null;
  can_transfer = null;
  can_update = null;
};

func onInitializeICRC7(newClass : ICRC7.ICRC7) : async* (){
  
};

func storageChangeICRC7(state : ICRC7.State) : (){
    icrc7_migration_state := state;
};

func getICRC7Class<system>(args: ICRC7.InitArgs) : ICRC7.ICRC7 {
  let manager = ClassPlusLib.ClassPlusInitializationManager(testOwner, get_canister(), false);
  let aClass = ICRC7.Init<system>({
    manager = manager;
    initialState = ICRC7.initialState();
    args = args;
    pullEnvironment =  ?getEnvironment_ICRC7;
    onInitialize = ?onInitializeICRC7;
    onStorageChange = storageChangeICRC7
  });
  
  return aClass();
};

var icrc37_migration_state = ICRC37.initialState();

func get_icrc37_state(): ICRC37.CurrentState{
  let #v0_1_0(#data(icrc37_state_current)) = icrc37_migration_state; 
  icrc37_state_current;
}; 



func get_icrc37_environment(icrc7 : ICRC7.ICRC7) : () -> ICRC37.Environment{

 return func() : ICRC37.Environment{
  {
    canister = get_canister;
    get_time = get_time;
    refresh_state = get_icrc37_state;
    icrc7 = icrc7;
    can_approve_token = null;
    can_approve_collection = null;
    can_revoke_token_approval = null;
    can_revoke_collection_approval = null;
    can_transfer_from = null;
  } : ICRC37.Environment};
};




func onInitializeICRC37(newClass : ICRC37.ICRC37) : async* (){
  
};

func storageChangeICRC37(state : ICRC37.State) : (){
    icrc37_migration_state := state;
};

func getICRC37Class<system>(args: ICRC37.InitArgs, icrc7 : ICRC7.ICRC7) : ICRC37.ICRC37 {
  let manager = ClassPlusLib.ClassPlusInitializationManager(testOwner, get_canister(), false);
  let aClass = ICRC37.Init<system>({
    manager = manager;
    initialState = ICRC37.initialState();
    args = args;
    pullEnvironment =  ?get_icrc37_environment(icrc7);
    onInitialize = ?onInitializeICRC37;
    onStorageChange = storageChangeICRC37
  });
  
  return aClass();
};






testsys<system>("max_revoke_approvals can be initialized", func<system>() {
   let icrc7 = getICRC7Class<system>(?baseCollection);
   let icrc37 = getICRC37Class<system>(?base37Collection, icrc7);
  assert(icrc37.get_ledger_info().max_revoke_approvals == 106);
  ignore icrc37.update_ledger_info([#MaxRevokeApprovals(1000)]);
  assert(icrc37.get_ledger_info().max_revoke_approvals == 1000);
  ignore icrc37.update_ledger_info([#MaxApprovals(1001)]);
  assert(icrc37.get_ledger_info().max_approvals == 1001);
  ignore icrc37.update_ledger_info([#SettleToApprovals(991)]);
  assert(icrc37.get_ledger_info().settle_to_approvals == 991);
});


testsys<system>("ICRC7 contract initializes with correct default state", func<system>() {
   let icrc7 = getICRC7Class<system>(?baseCollection);
   let icrc37 = getICRC37Class<system>(?base37Collection, icrc7);
  D.print(debug_show(icrc37.get_ledger_info()));
  
  assert(icrc37.get_ledger_info().max_approvals_per_token_or_collection == 101);
  assert(icrc37.get_ledger_info().max_revoke_approvals == 106);
  assert(icrc37.get_ledger_info().max_approvals == 500);
  assert(icrc37.get_ledger_info().settle_to_approvals == 450);
});

testsys<system>("Approve another account for a set of token transfers", func<system>() {
  // Arrange: Set up the ICRC7 instance and approval parameters
   let icrc7 = getICRC7Class<system>(?baseCollection);
   let icrc37 = getICRC37Class<system>(?base37Collection, icrc7);

  let tokenOwner = testOwner;  // Replace with appropriate owner principal
  let spender = {owner = testCanister; subaccount = null};  // Replace with appropriate spender principal
  let approvedTokenIds = [1, 2, 3, 9, 10];  // Replace with appropriate token IDs
  let token_ids = [1, 2, 3, 4, 5, 6, 7, 8 ,9, 10]; // Assuming tokens with IDs 1, 2, and 3 have been minted with known metadata
  
  let metadata1 = baseNFT;

  let approvalInfos = Vec.new<ICRC37.TokenApproval>();
  for(thisItem in token_ids.vals()){

    let #ok(metadata) = Properties.updatePropertiesShared(CandyConv.candySharedToProperties(baseNFT), [{
      name = "url";
      mode = #Set(#Text("https://example.com/" # Nat.toText(thisItem)))
    }]) else return assert(false);

    let nft = icrc7.set_nfts<system>(testOwner, [{
      token_id= thisItem;
      override=true;
      metadata=#Class(metadata);
      owner= if(thisItem > 3){null} else {?testOwnerAccount};
      memo=null;
      created_at_time=null;
    }],false);

      Vec.add(approvalInfos, {
        token_id = thisItem;
          approval_info = {
          memo = ?Text.encodeUtf8("Approval memo");
          expires_at = ?(init_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
          created_at_time = ?init_time : ?Nat64;  // Replace with appropriate creation timestamp
          from_subaccount = null;
          
          spender = spender;
        };
      } : ICRC37.TokenApproval );
  

  };

  // Act: Approve the spender for the specified token transfers
  let #ok(approvalResponses) = icrc37.approve_transfers<system>(tokenOwner, Vec.toArray(approvalInfos)) else return assert(false);

  D.print("approvalResponses" # debug_show(approvalResponses));

  // Assert: Check if the approvals are correctly recorded
  assert(
    approvalResponses.size() == 10
  ); //"Correct number of approvals recorded"

  let ?#Ok(approvalResponseId) = approvalResponses[0] else return assert(false); 
  assert(
    approvalResponseId > 0
  );//"First approval record for token with ID 1"

  let ?#Err(approvalResponseId4) = approvalResponses[3] else return assert(false); 


  // Test pagination of tokens owned by the account
  let approvedTokens1 = icrc37.is_approved(
    [{spender; from_subaccount = null; token_id = 3;}]
  )[0];
  
  // Assert: Check if approved for the item

  assert(approvedTokens1 == true)//"approval exists"
});


testsys<system>("Check approval requests for expiry and creation times", func<system>() {
  // Arrange: Set up the ICRC7 instance and approval parameters
   let icrc7 = getICRC7Class<system>(?baseCollection);
   let icrc37 = getICRC37Class<system>(?base37Collection, icrc7);

  let tokenOwner = testOwner;  // Replace with appropriate owner principal
  let expiredTimestamp = test_time - 10;  // Assume an expired timestamp
  let futureTimestamp = test_time + Nat64.fromNat(Int.abs(icrc7.get_ledger_info().permitted_drift)) + 1;  // Assume a future timestamp
  let oldTimestamp = test_time - Nat64.fromNat(Int.abs(icrc7.get_ledger_info().permitted_drift)) - 1;  // Assume a old timestamp

  let tokenIds = [1, 2];  // Replace with appropriate token IDs
  let spender = {owner = testCanister; subaccount = null};  // Replace with appropriate spender principal
  let invalidApprovalInfo1 =  [{
    token_id = 1;
    approval_info = {
    memo = ?Text.encodeUtf8("Expired approval memo");
    expires_at = ?expiredTimestamp: ?Nat64;  // Set an expired expiry timestamp
    created_at_time = ?test_time : ?Nat64;  // Replace with appropriate creation timestamp
    from_subaccount = null;
    spender = spender;
  }}];

  let invalidApprovalInfo2 =  [{
    token_id = 1;
    approval_info = {
    memo = ?Text.encodeUtf8("Future approval memo");
    expires_at = ?(test_time + one_day): ?Nat64;  // Set a future expiry timestamp
    created_at_time = ?futureTimestamp : ?Nat64;  // Replace with appropriate creation timestamp
    from_subaccount = null;
    spender = spender;
  }}];

  let invalidApprovalInfo3 = [{
    token_id = 1;
    approval_info = {
      memo = ?Text.encodeUtf8("Future approval memo");
      expires_at = ?(test_time + one_minute): ?Nat64;  // Set a future expiry timestamp
      created_at_time = ?oldTimestamp : ?Nat64;  // Replace with appropriate creation timestamp
      from_subaccount = null;
      spender = spender;
  }}];
  //D.print(debug_show(icrc37.approve_transfers<system>(tokenOwner, tokenIds, invalidApprovalInfo1)));
  // Act: Attempt approval requests with expired and future timestamps
  let #ok(approvalResponsesExpired) = icrc37.approve_transfers<system>(tokenOwner, invalidApprovalInfo1) else return assert(false);

  let #ok(approvalResponsesFuture) = icrc37.approve_transfers<system>(tokenOwner,  invalidApprovalInfo2) else return assert(false);

  let ?#Err(#CreatedInFuture(err1)) =approvalResponsesFuture[0] else return assert(false);

  let #ok(approvalResponsesOld) = icrc37.approve_transfers<system>(tokenOwner,  invalidApprovalInfo3) else return assert(false);

  let ?#Err(err2) = approvalResponsesOld[0] else return assert(false);

  D.print("Approval results: " # debug_show(approvalResponsesExpired, approvalResponsesFuture, approvalResponsesOld));

});


testsys<system>("Check approval errors for improper from_subaccount and non-existing token", func<system>() {
  // Arrange: Set up the ICRC7 instance and approval parameters
   let icrc7 = getICRC7Class<system>(?baseCollection);
   let icrc37 = getICRC37Class<system>(?base37Collection, icrc7);

  let token_id = 1;  // Assuming token with ID 1 exists
  let metadata = baseNFT;
  D.print("about to set" # debug_show(metadata));
  let nft = icrc7.set_nfts<system>(testOwner,[{
    token_id=token_id;
    override=true;
    metadata=metadata;
    owner= ?testOwnerAccount;
    memo=null;
    created_at_time=null;
  }],false);


  let tokenOwner = testOwner;  // Replace with appropriate token owner principal
  let tokenWithSubaccount = 1;  // Replace with appropriate token ID that's held in a specific subaccount
  let nonExistingToken = 9999;  // Assume a non-existing token ID
  let improperApprovalInfo1 = [{
    token_id = token_id;
    approval_info = {
      memo = ?Text.encodeUtf8("Improper subaccount approval memo");
      expires_at = null: ?Nat64;  // Set no expiration timestamp
      created_at_time = null: ?Nat64;  // Set no creation timestamp
      from_subaccount = ?Blob.fromArray([0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1]);  // Set an improper subaccount
      spender = {owner = testCanister; subaccount = null};  // Replace with appropriate spender principal
    };
  }];

  let invalidApprovalInfo2 = [{
    token_id = nonExistingToken;
    approval_info = {
      memo = ?Text.encodeUtf8("Non-existing token approval memo");
      expires_at = null: ?Nat64;  // Set no expiration timestamp
      created_at_time = null: ?Nat64;  // Set no creation timestamp
      from_subaccount = null;  // Set from_subaccount as null
      spender = {owner = testCanister; subaccount = null};  // Replace with appropriate spender principal
    };
  }];

  // Act: Attempt approval requests with an improper from_subaccount and a non-existing token
  let #ok(approvalResponseImproperSubaccount) = icrc37.approve_transfers<system>(tokenOwner, improperApprovalInfo1) else return assert(false);

  let ?approvalResponseImproperSubaccountItem = approvalResponseImproperSubaccount[0];

  let #ok(approvalResponseNonExistingToken) = icrc37.approve_transfers<system>(tokenOwner, invalidApprovalInfo2) else return assert(false);

  D.print("Improper approval results: " # debug_show(approvalResponseImproperSubaccount));
  D.print("Non-existing token approval results: " # debug_show(approvalResponseNonExistingToken));

  let ?approvalResponseNonExistingTokenItem = approvalResponseNonExistingToken[0];

  // Assert: Check if the expected errors are returned for an improper from_subaccount and non-existing token
  let #Err(improperSubaccountError) = approvalResponseImproperSubaccountItem else return assert(false);
  let #Err(nonExistingTokenError) = approvalResponseNonExistingTokenItem else return assert(false);

  assert(
    improperSubaccountError == #Unauthorized
  );

  assert(
    nonExistingTokenError == #NonExistingTokenId
  );
});

testsys<system>("Approve another account for all transfers in the collection and paginate query results", func<system>() {
  // The ICRC7 class and base environment are set up from the provided framework
   let icrc7 = getICRC7Class<system>(?baseCollection);
   let icrc37 = getICRC37Class<system>(?base37Collection, icrc7);

  let approvedSpender = spender1;

  let token_ids = [1, 2, 3, 4, 5, 6, 7, 8 ,9, 10]; // Assuming tokens with IDs 1, 2, and 3 have been minted with known metadata
  
  let metadata1 = baseNFT;
  for(thisItem in token_ids.vals()){

    

    let nft = icrc7.set_nfts<system>(testOwner, [{memo=null;created_at_time=null;token_id=thisItem;override=true;metadata=baseNFT;owner=?(
      if(thisItem < 6){ 
        testOwnerAccount
      } else {
        {owner = testCanister; subaccount = null}
      })}],false);

  };

  // Act: Approve another account for all transfers in the collection
  let approvalArgs = { 
    approval_info = {
      token_id = null;
      memo = null;
      expires_at = null;
      created_at_time = null;
      from_subaccount = null;
      spender = approvedSpender;
    }
  }; 

  let approvalResponse = icrc37.approve_collection_transfer<system>(testOwner, approvalArgs);
  let approvalResponse1 = icrc37.approve_collection_transfer<system>(testOwner, {approvalArgs with approval_info = {approvalArgs.approval_info with spender = spender2}});
  let approvalResponse2 = icrc37.approve_collection_transfer<system>(testOwner, {approvalArgs with approval_info = {approvalArgs.approval_info with spender = spender3}});
  let approvalResponse3 = icrc37.approve_collection_transfer<system>(testOwner, {approvalArgs with approval_info = {approvalArgs.approval_info with spender = spender4}});
  let approvalResponse4 = icrc37.approve_collection_transfer<system>(testOwner, {approvalArgs with approval_info = {approvalArgs.approval_info with spender = spender5}});

  D.print("Approval results: " # debug_show(approvalResponse, approvalResponse1, approvalResponse2, approvalResponse3, approvalResponse4));


  switch(approvalResponse, approvalResponse1, approvalResponse2, approvalResponse3, approvalResponse4){
    case(#ok(val1),#ok(val2),#ok(val3),#ok(val4),#ok(val5)){
      
    };
    case(_){
       return assert(false);
    };
  };
  

  

  // Pagination test
  let tokenIds = [1, 2, 3];  // Assume there are tokens 1, 2, 3 in the collection.
  var prevApprovalInfo : ?ICRC37.CollectionApproval = null;  // Initial page

  // Collect all approval responses
  let #ok(allApprovalResponses) = icrc37.collection_approvals({owner = testOwner; subaccount=null}, prevApprovalInfo, ?3) else return assert(false);

   D.print("Approval page1: " # debug_show(allApprovalResponses));

  if (Array.size(allApprovalResponses) == 3) {
    // Other tests here for successfully fetching all approvals on first paginated request
  } else {
    assert(false);  // Paginated request did not return all expected approvals
  };

  // Next  page test
  prevApprovalInfo := ?allApprovalResponses[2]; // Set the last approval as previous for the next paginated request
  let #ok(allApprovalResponses2) = icrc37.collection_approvals({owner = testOwner; subaccount=null}, prevApprovalInfo, ?3);

  D.print("Approval page2: " # debug_show(allApprovalResponses2));

  if (Array.size(allApprovalResponses2) == 2) {
    // All approvals fetched successfully from subsequent pages
  } else {
    assert(false);  // Subsequent paginated request did not return expected approvals
  }
});



testsys<system>("Check collection approval requests for expiry and creation times", func<system>() {
   let icrc7 = getICRC7Class<system>(?baseCollection);
   let icrc37 = getICRC37Class<system>(?base37Collection, icrc7);

  let expiredTimestamp = test_time - 10;  // Assume an expired timestamp
  let futureTimestamp = test_time + Nat64.fromNat(Int.abs(icrc7.get_ledger_info().permitted_drift)) + 1;  // Assume a future timestamp
  let oldTimestamp = test_time - Nat64.fromNat(Int.abs(icrc7.get_ledger_info().permitted_drift)) - 1;  // Assume an old timestamp
  
  let spender = {owner = testCanister; subaccount = null};  // Replace with appropriate spender principal
  let invalidApprovalInfo1 = {
    approval_info = {
      memo = ?Text.encodeUtf8("Expired approval memo");
      expires_at = ?expiredTimestamp: ?Nat64;  // Set an expired expiry timestamp
      created_at_time = ?test_time : ?Nat64;  // Replace with appropriate creation timestamp
      spender = spender1;
      from_subaccount = null;
    };
  };

  let invalidApprovalInfo2 = {
    approval_info = {
      memo = ?Text.encodeUtf8("Future approval memo");
      expires_at = ?(test_time + one_day): ?Nat64;  // Set a future expiry timestamp
      created_at_time = ?futureTimestamp : ?Nat64;  // Replace with appropriate creation timestamp
      spender = spender1;
      from_subaccount = null;
    };
  };

  let invalidApprovalInfo3 = {
    approval_info = {
      memo = ?Text.encodeUtf8("Future approval memo");
      expires_at = ?(test_time + one_minute): ?Nat64;  // Set a future expiry timestamp
      created_at_time = ?oldTimestamp : ?Nat64;  // Replace with appropriate creation timestamp
      spender = spender1;
      from_subaccount = null;
    };
  };

  // Act: Attempt collection approval requests with expired and future timestamps
  let approvalResponsesExpired = icrc37.approve_collection_transfer<system>(testOwner, invalidApprovalInfo1);
 

  let approvalResponsesFuture = icrc37.approve_collection_transfer<system>(testOwner, invalidApprovalInfo2);
 

  let approvalResponsesOld = icrc37.approve_collection_transfer<system>(testOwner, invalidApprovalInfo3);
 
  D.print("Approval results: " # debug_show(approvalResponsesExpired, approvalResponsesFuture, approvalResponsesOld));

   let #ok(?#Err(#GenericError(approvalResponsesExpiredx))) = approvalResponsesExpired else return assert(false);

   assert(approvalResponsesExpiredx.error_code == 48575);

   let #ok(?#Err(approvalResponsesFuturex)) = approvalResponsesFuture else return assert(false);

   let #ok(?#Err(approvalResponsesOldx)) = approvalResponsesOld else return assert(false);

});


testsys<system>("Check approval errors when owner doesn't own tokens in the collection", func<system>() {
  // Arrange: Set up the ICRC7 instance and approval parameters
   let icrc7 = getICRC7Class<system>(?baseCollection);
   let icrc37 = getICRC37Class<system>(?base37Collection, icrc7);

  let tokenOwner = testOwner;  // Replace with appropriate token owner principal
  
  let ownerWithoutTokens = spender1;  // Replace with an owner who doesn't own any tokens in the collection
  
  let approvalInfo = {
    approval_info = {
      memo = ?Text.encodeUtf8("Approval with no owned tokens memo");
      expires_at = null: ?Nat64;  // Set no expiration timestamp
      created_at_time = null: ?Nat64;  // Set no creation timestamp
      from_subaccount = null;  // Replace with an appropriate subaccount
      spender = spender2;
    };
  };

  // Act: Attempt approval requests for non-existing token and owner without tokens
  let #ok(approvalResponseOwnerWithoutTokens) = icrc37.approve_collection_transfer<system>(spender1.owner, approvalInfo) else return assert(false);

  
  D.print("Owner without tokens approval results: " # debug_show(approvalResponseOwnerWithoutTokens));

  // Assert: Check if the expected errors are returned for non-existing and owner without tokens scenarios
  let ?#Err(ownerWithoutTokensError) = approvalResponseOwnerWithoutTokens else return assert(false);

  assert(
    ownerWithoutTokensError == #Unauthorized
  );
});

testsys<system>("Reject Approval Attempt by Unauthorized User", func<system>() {
  // Arrange: Set up the ICRC7 instance, current test environment, and required variables
   let icrc7 = getICRC7Class<system>(?baseCollection);
   let icrc37 = getICRC37Class<system>(?base37Collection, icrc7);

  let token_id = 1;  // Assuming token with ID 1 exists
  let metadata = baseNFT;
  D.print("about to set" # debug_show(metadata));
  let nft = icrc7.set_nfts<system>(testOwner, [{
    token_id=token_id;
    override=true;
    metadata=metadata;
    owner= ?testOwnerAccount;
    memo=null;
    created_at_time=null;
  }],false);


  let unauthorizedOwner = spender1;  // Replace with an unauthorized owner principal
  let unauthorizedApprovalArgs = [{
    token_id = 1;
    approval_info = {
      from_subaccount = unauthorizedOwner.subaccount;
      spender  = spender2;
      memo = ?Text.encodeUtf8("Unauthorized transfer attempt");
      expires_at = null;
        // Replace with appropriate token ID for a token that the unauthorized owner owns
      created_at_time = ?init_time : ?Nat64;  // Replace with appropriate creation timestamp
    };
  }];

  // Act: Attempt to transfer a token by an unauthorized user
  let #ok(approvalResponses) = icrc37.approve_transfers<system>(spender1.owner, unauthorizedApprovalArgs) else return assert(false);

  // Assert: Check if the transfer attempt is rejected
  assert(
    approvalResponses.size() == 1
  ); //"Exactly one transfer response"

  let ?approalResponseItem = approvalResponses[0];

  assert(
    (switch(approalResponseItem) {
      case (#Err(err)) true;
      case (#Ok(val)) false;
    })
  ); //"Transfer attempt is rejected"
});


testsys<system>("Transfer a token to another account after approval", func<system>() {
  // ARRANGE: Set up the ICRC7 instance and required approvals
   let icrc7 = getICRC7Class<system>(?baseCollection);
   let icrc37 = getICRC37Class<system>(?base37Collection, icrc7);

  let token_id = 1;  // Assuming token with ID 1 exists
  let metadata = baseNFT;
  D.print("about to set" # debug_show(metadata));
  let nft = icrc7.set_nfts<system>(testOwner,  [{
    token_id=token_id;
    override=true;
    metadata=metadata;
    owner= ?testOwnerAccount;
    memo=null;
    created_at_time=null;
  }],false);

  let tokenOwner = testOwner;  // Replace with appropriate owner principal
  let spender = spender1;  // Replace with appropriate spender principal
  let approvedTokenId = 1;  // Replace with the appropriate token ID
  let transferArgs = [{
    from = {owner = tokenOwner; subaccount = null};  // Replace with the appropriate previous owner's principal
    to = {owner = testCanister; subaccount = null};  // Replace with the appropriate recipient's principal
    memo = ?Text.encodeUtf8("Transfer memo");  // Optionally set a memo
    created_at_time = ?test_time: ?Nat64;  // Replace with an appropriate creation timestamp
    spender_subaccount = spender1.subaccount;
    token_id = approvedTokenId;
  }];

  // Prepare the approval information
  var approvalInfo = [{
    token_id = token_id;
    approval_info = {
      memo = ?Text.encodeUtf8("Approval memo");
      expires_at = ?(test_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
      created_at_time = ?test_time : ?Nat64;  // Replace with appropriate creation timestamp
      from_subaccount = null;
      spender = spender;
    };
  }];

  // Create the approval for the token transfer
  let approvalResponses = icrc37.approve_transfers<system>(tokenOwner, approvalInfo);

  // ACT: Initiate the transfer of the approved token
  let #ok(transferResponse) = icrc37.transfer<system>(spender.owner, transferArgs) else return assert(false);

  D.print("result is " # debug_show(approvalResponses, transferResponse));

  // ASSERT: Ensure that the transfer has been successful
  let  ?transferResponseItem = transferResponse[0];
  assert(
    (switch(transferResponseItem) {
      case (#Ok(trx_id)) true;
      case (_) false;
    })
  );  //"Token transfer was successful"

  // Query for the owner of the token after transfer
  let ?ownerResponse = icrc7.get_token_owner(token_id);

   
  assert(ownerResponse.owner == testCanister);
  assert(ownerResponse.subaccount == null);
     

  //make sure the approval was cleared
  // Query for the owner of the token after transfer
  let approval_list_after = icrc37.get_approvals([approvedTokenId], null, null);

    (switch(approval_list_after) {
      case (#ok(list)) {
        assert(list.size() == 0);
      };
      case (_) return assert(false);
    });
});


testsys<system>("Transfer a token to another account after collection approval", func<system>() {
  // ARRANGE: Set up the ICRC7 instance and required approvals
   let icrc7 = getICRC7Class<system>(?baseCollection);
   let icrc37 = getICRC37Class<system>(?base37Collection, icrc7);

  let token_id = 1;  // Assuming token with ID 1 exists
  let metadata = baseNFT;
  D.print("about to set" # debug_show(metadata));
  let nft = icrc7.set_nfts<system>(testOwner,  [{
    token_id=token_id;
    override=true;
    metadata=metadata;
    owner= ?testOwnerAccount;
    memo=null;
    created_at_time=null;
  }],false);

  let tokenOwner = testOwner;  // Replace with appropriate owner principal
  let spender = spender1;  // Replace with appropriate spender principal
  let approvedTokenId = 1;  // Replace with the appropriate token ID
  let transferArgs = [{
    from = {owner = tokenOwner; subaccount = null};  // Replace with the appropriate previous owner's principal
    to = {owner = testCanister; subaccount = null};  // Replace with the appropriate recipient's principal
    memo = ?Text.encodeUtf8("Transfer memo");  // Optionally set a memo
    created_at_time = ?test_time: ?Nat64;  // Replace with an appropriate creation timestamp
    spender_subaccount = spender1.subaccount;
    token_id = approvedTokenId;
  }];

  // Prepare the approval information
  var approvalInfo = {
    approval_info = {
      memo = ?Text.encodeUtf8("Approval memo");
      expires_at = ?(test_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
      created_at_time = ?test_time : ?Nat64;  // Replace with appropriate creation timestamp
      from_subaccount = null;
      spender = spender;
    };
  };

  // Create the approval for the token transfer
  let approvalResponses = icrc37.approve_collection_transfer<system>(tokenOwner, approvalInfo);

  assert(icrc37.is_approved([{spender; from_subaccount = null; token_id = 0;}])[0]);

  assert(not icrc37.is_approved([{spender; from_subaccount = ?Blob.fromArray([1]); token_id = 0;}])[0]);

  // ACT: Initiate the transfer of the approved token
  let #ok(transferResponse) = icrc37.transfer<system>(spender.owner, transferArgs) else return assert(false);

  let ?transferResponseItem = transferResponse[0];

  // ASSERT: Ensure that the transfer has been successful
  assert(
    (switch(transferResponseItem) {
      case (#Ok(trx_id)) true;
      case (_) false;
    })
  );  //"Token transfer was successful"

  // Query for the owner of the token after transfer
  let ?ownerResponse = icrc7.get_token_owner(token_id);


  assert(ownerResponse.owner == testCanister);
  assert(ownerResponse.subaccount == null);

  let tokens_of = icrc7.tokens_of({owner = testCanister; subaccount = null}, null, null);

  D.print("tokens_of" # debug_show(tokens_of));

  assert(tokens_of[0] == 1);

  let tokens_of2 = icrc7.tokens_of(testOwnerAccount, null, null);

  D.print("tokens_of2" # debug_show(tokens_of2));

  assert(tokens_of2.size() == 0);
});


testsys<system>("Clean up should limit number of approvals and log transactions", func<system>() {
  // ARRANGE: Set up the ICRC7 instance and required approvals
   let icrc7 = getICRC7Class<system>(?baseCollection);
   let icrc37 = getICRC37Class<system>(?base37Collection, icrc7);

  let metadata = baseNFT;
  D.print("about to set" # debug_show(metadata));
  

  let tokenOwner = testOwner;  // Replace with appropriate owner principal
  let spender = spender1;  // Replace with appropriate spender principal
  let approvedTokenId = 1;  // Replace with the appropriate token ID

  ignore icrc37.update_ledger_info([#MaxApprovals(8)]);
  ignore icrc37.update_ledger_info([#SettleToApprovals(4)]);
  
  for(thisItem in Iter.range(0,9)){
    let token_id = thisItem;  
    let metadata = baseNFT;
    D.print("about to set" # debug_show(metadata));
    let nft = icrc7.set_nfts<system>(testOwner, [{
      token_id=thisItem;
      override=true;
      metadata=metadata;
      owner= ?testOwnerAccount;
      memo=null;
      created_at_time=null;
    }],false);

    // Prepare the approval information
    var approvalInfo = [{
      token_id = thisItem;
      approval_info = {
        memo = ?Text.encodeUtf8("Approval memo");
        expires_at = ?(test_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
        created_at_time = ?test_time : ?Nat64;  // Replace with appropriate creation timestamp
        from_subaccount = null;
        spender = spender;
      };
    }];

    // Create the approval for the token transfer
    let approvalResponses = icrc37.approve_transfers<system>(tokenOwner,  approvalInfo);

  };

  assert(icrc37.is_approved([{spender; from_subaccount = null; token_id = 0;}])[0] == false);
  assert(icrc37.is_approved([{spender; from_subaccount = null; token_id = 1;}])[0] == false);
  assert(icrc37.is_approved([{spender; from_subaccount = null; token_id = 2;}])[0] == false);
  assert(icrc37.is_approved([{spender; from_subaccount = null; token_id = 3;}])[0] == false);

  assert(icrc37.is_approved([{spender; from_subaccount = null; token_id = 6;}])[0] == true);
  assert(icrc37.is_approved([{spender; from_subaccount = null; token_id = 7;}])[0] == true);
  assert(icrc37.is_approved([{spender; from_subaccount = null; token_id = 8;}])[0] == true);
  assert(icrc37.is_approved([{spender; from_subaccount = null; token_id = 9;}])[0] == true);

  D.print("the ledger:" # debug_show(ICRC7.Vec.toArray(icrc7.get_state().ledger)));
  assert(ICRC7.Vec.size(icrc7.get_state().ledger) > 10);

      
});


testsys<system>("Too many approvals should trap", func<system>() {
  // ARRANGE: Set up the ICRC7 instance and required approvals
   let icrc7 = getICRC7Class<system>(?baseCollection);
   let icrc37 = getICRC37Class<system>(?base37Collection, icrc7);

  let metadata = baseNFT;
  D.print("about to set" # debug_show(metadata));

  let tokenOwner = testOwner;  // Replace with appropriate owner principal
  let spender = spender1;  // Replace with appropriate spender principal
  let approvedTokenId = 1;  // Replace with the appropriate token ID

  ignore icrc37.update_ledger_info([#MaxApprovalsPerTokenOrColletion(8)]);

  let approvalInfo = Vec.new<Service.ApproveTokenArg>();

  for(thisItem in Iter.range(0,9)){
    let token_id = thisItem;  
    let metadata = baseNFT;
    D.print("about to set" # debug_show((thisItem, metadata)));
    let nft = icrc7.set_nfts<system>(testOwner,  [{
      token_id=token_id;
      override=true;
      metadata=metadata;
      owner= ?testOwnerAccount;
      memo=null;
      created_at_time=null;

    
    }],false);

    Vec.add(approvalInfo, {
      token_id = thisItem;
        approval_info = {
          memo = ?Text.encodeUtf8("Approval memo");
          expires_at = ?(test_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
          created_at_time = ?test_time : ?Nat64;  // Replace with appropriate creation timestamp
          from_subaccount = null;
          spender = spender;
        };
      });
  };

    assert(Vec.size(approvalInfo) == 10);
    D.print("approvalInfo" # debug_show(approvalInfo)); 
    let #ok(approvalResponses) = icrc37.approve_transfers<system>(tokenOwner, Vec.toArray(approvalInfo));
    D.print("approval result: " # debug_show(approvalResponses));

  for(thisItem in Iter.range(0,9)){
    // Create the approval for the token transfer
    if(thisItem < 8){
      let ?#Ok(approvalResponsesok) = approvalResponses[thisItem] else return assert(false);
      D.print(debug_show(approvalResponses[thisItem]));
    } else if(thisItem == 8){
      let ?#Err(#GenericBatchError(approvalResponseserr)) = approvalResponses[thisItem] else return assert(false);
    } else {
      assert(approvalResponses.size()==9);
    }
  };
});


testsys<system>("Transfer a token to another account after collection approval", func<system>() {
  // ARRANGE: Set up the ICRC7 instance and required approvals
   let icrc7 = getICRC7Class<system>(?baseCollection);
   let icrc37 = getICRC37Class<system>(?base37Collection, icrc7);

  let token_id = 1;  // Assuming token with ID 1 exists
  let metadata = baseNFT;
  D.print("about to set" # debug_show(metadata));
  let nft = icrc7.set_nfts<system>(testOwner,  [{
    token_id=token_id;
    override=true;
    metadata=metadata;
    owner= ?testOwnerAccount;
    memo=null;
    created_at_time=null;
  }],false);

  let tokenOwner = testOwner;  // Replace with appropriate owner principal
  let spender = spender1;  // Replace with appropriate spender principal
  let approvedTokenId = 1;  // Replace with the appropriate token ID
  let transferArgs = [{
    from = {owner = tokenOwner; subaccount = null};  // Replace with the appropriate previous owner's principal
    to = {owner = testCanister; subaccount = null};  // Replace with the appropriate recipient's principal
    memo = ?Text.encodeUtf8("Transfer memo");  // Optionally set a memo
    created_at_time = ?test_time: ?Nat64;  // Replace with an appropriate creation timestamp
    spender_subaccount = spender1.subaccount;
    token_id = approvedTokenId;
  }];

  // Prepare the approval information
  var approvalInfo = {
    approval_info = {
      memo = ?Text.encodeUtf8("Approval memo");
      expires_at = ?(test_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
      created_at_time = ?test_time : ?Nat64;  // Replace with appropriate creation timestamp
      from_subaccount = null;
      spender = spender;
    };
  };

  // Create the approval for the token transfer
  let approvalResponses = icrc37.approve_collection_transfer<system>(tokenOwner, approvalInfo);

  assert(icrc37.is_approved([{spender; from_subaccount = null; token_id = 1;}])[0]);

  assert(not icrc37.is_approved([{spender; from_subaccount = ?Blob.fromArray([1]); token_id = 1;}])[0]);

  // ACT: Initiate the transfer of the approved token
  let #ok(transferResponse) = icrc37.transfer(spender.owner, transferArgs) else return assert(false);

  let ?transferResponseItem = transferResponse[0];
  // ASSERT: Ensure that the transfer has been successful
  assert(
    (switch(transferResponseItem) {
      case (#Ok(trx_id)) true;
      case (_) false;
    })
  );  //"Token transfer was successful"

  // Query for the owner of the token after transfer
  let ?ownerResponse = icrc7.get_token_owner(token_id);


  assert(ownerResponse.owner == testCanister);
  assert(ownerResponse.subaccount == null);
   
      
});



testsys<system>("Revoke a single approval on a token", func<system>() {
  // Arrange: Set up the ICRC7 instance and approval parameters
   let icrc7 = getICRC7Class<system>(?baseCollection);
   let icrc37 = getICRC37Class<system>(?base37Collection, icrc7);

  let tokenOwner = testOwner;  // Replace with appropriate owner principal
  let spender = spender1;  // Replace with appropriate spender principal
  let approvedTokenId = 1;  // Replace with the approved token’s ID

  let metadata = baseNFT;
  D.print("about to set" # debug_show(metadata));
  let nft = icrc7.set_nfts<system>(testOwner,  [{
    token_id= approvedTokenId;
    override=true;
    metadata=metadata;
    owner= ?testOwnerAccount;
    memo=null;
    created_at_time=null;
  }],false);
  
  // Create approval
  let approvalInfo = [{
    token_id = approvedTokenId;
    approval_info ={
      memo = ?Text.encodeUtf8("Approval memo");
      expires_at = ?(init_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
      created_at_time = ?init_time : ?Nat64;  // Replace with appropriate creation timestamp
      from_subaccount = null;
      spender = spender1;
    };
  }];
  
  let approvalResponses = icrc37.approve_transfers<system>(tokenOwner, approvalInfo);

  // Create approval
  let approvalInfo2 = [{
    token_id =  approvedTokenId;
    approval_info ={
      memo = ?Text.encodeUtf8("Approval memo");
      expires_at = ?(init_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
      created_at_time = ?init_time : ?Nat64;  // Replace with appropriate creation timestamp
      from_subaccount = null;
      spender = spender2;
    };
  }];
  
  let approvalResponses2 = icrc37.approve_transfers<system>(tokenOwner,  approvalInfo2);

  D.print("approvalResponses2" # debug_show(approvalResponses2));

  let #ok(tokenApprovalsAfterRevocation2) = icrc37.get_approvals([approvedTokenId], null, null) else return assert(false);

  D.print("approval list" # debug_show(tokenApprovalsAfterRevocation2));

  assert(tokenApprovalsAfterRevocation2.size() == 2);

  // Act: Revoke the single approval on the specified token
  let revokeArgs = [{
    token_id = approvedTokenId;
    spender = ?spender1;
    from_subaccount = null;
    memo = null;
    created_at_time = ?init_time;
  }];

  let #ok(revokeResponse) = icrc37.revoke_tokens<system>(tokenOwner, revokeArgs) else return assert(false);
  D.print("revokeResponse" # debug_show(revokeResponse));

  // Assert: Check if the approval is correctly revoked and the ledger is updated
  assert(
    revokeResponse.size() == 1
  ); // "Single approval revoked"
  let ?revokeResponseItem = revokeResponse[0];
  assert(
    (switch(revokeResponseItem) {
      case (#Ok(transaction_id)) true;
      case(_) false;
    }) 
  ); // "Revoke result indicates success"

  assert(not icrc37.is_approved([{spender; from_subaccount = null; token_id = 1;}])[0]);

  // Query for approvals of the token after revocation
  let #ok(tokenApprovalsAfterRevocation) = icrc37.get_approvals([approvedTokenId], null, null) else return assert(false);

  D.print("tokenApprovalsAfterRevocation" # debug_show(tokenApprovalsAfterRevocation));


  // Assert: Check if only one approval remains after revocation
  assert(tokenApprovalsAfterRevocation.size() == 1); // "Single approval remaining after revocation"
  assert(ICRC7.account_eq(tokenApprovalsAfterRevocation[0].approval_info.spender,spender2));
  


});



testsys<system>("Revoke all approval on a token", func<system>() {
  // Arrange: Set up the ICRC7 instance and approval parameters
   let icrc7 = getICRC7Class<system>(?baseCollection);
   let icrc37 = getICRC37Class<system>(?base37Collection, icrc7);

  let tokenOwner = testOwner;  // Replace with appropriate owner principal
  let spender = spender1;  // Replace with appropriate spender principal
  let approvedTokenId = 1;  // Replace with the approved token’s ID

  let metadata = baseNFT;
  D.print("about to set" # debug_show(metadata));
  let nft = icrc7.set_nfts<system>(testOwner, [{
    token_id= approvedTokenId;
    override=true;
    metadata=metadata;
    owner= ?testOwnerAccount;
    memo=null;
    created_at_time=null;
  }],false);
  
  // Create approval
  let approvalInfo = [{
    token_id = approvedTokenId;
    approval_info = {
      
      memo = ?Text.encodeUtf8("Approval memo");
      expires_at = ?(init_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
      created_at_time = ?init_time : ?Nat64;  // Replace with appropriate creation timestamp
      from_subaccount = null;
      spender = spender1;
    };
  }];
  
  let approvalResponses = icrc37.approve_transfers<system>(tokenOwner,  approvalInfo);

  // Create approval
  let approvalInfo2 = [{
    token_id =  approvedTokenId;
    approval_info = {
      memo = ?Text.encodeUtf8("Approval memo");
      expires_at = ?(init_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
      created_at_time = ?init_time : ?Nat64;  // Replace with appropriate creation timestamp
      from_subaccount = null;
      spender = spender2;
    };
  }];
  
  let approvalResponses2 = icrc37.approve_transfers<system>(tokenOwner, approvalInfo2);

  D.print("approvalResponses2" # debug_show(approvalResponses2));

  let #ok(tokenApprovalsAfterRevocation2) = icrc37.get_approvals([approvedTokenId], null, null) else return assert(false);

  D.print("approval list" # debug_show(tokenApprovalsAfterRevocation2));

  assert(tokenApprovalsAfterRevocation2.size() == 2);

  // Act: Revoke the single approval on the specified token
  let revokeArgs = [{
    token_id = approvedTokenId;
    spender = null;
    from_subaccount = null;
    memo = null;
    created_at_time = ?init_time;
  }];

  let #ok(revokeResponse) = icrc37.revoke_tokens<system>(tokenOwner, revokeArgs)else return assert(false);
  D.print("revokeResponse" # debug_show(revokeResponse));

  // Assert: Check if the approval is correctly revoked and the ledger is updated
  assert(
    revokeResponse.size() == 1
  ); // "Single approval revoked"

  assert(not icrc37.is_approved([{spender; from_subaccount = null; token_id = 1;}])[0]);

  let ?revokeResponseItem = revokeResponse[0];

  assert(
    (switch(revokeResponseItem) {
      case (#Ok(transaction_id)) true;
      case(_) false;
    }) 
  ); // "Revoke result indicates success"

  // Query for approvals of the token after revocation
  let #ok(tokenApprovalsAfterRevocation) = icrc37.get_approvals([approvedTokenId], null, null) else return assert(false);

  D.print("tokenApprovalsAfterRevocation" # debug_show(tokenApprovalsAfterRevocation));


  // Assert: Check if only one approval remains after revocation
  assert(tokenApprovalsAfterRevocation.size() == 0); // "Single approval remaining after revocation"

});


testsys<system>("Revoke single collection approvals for an account", func<system>() {
  // Arrange: Set up the ICRC7 instance and approval parameters
   let icrc7 = getICRC7Class<system>(?baseCollection);
   let icrc37 = getICRC37Class<system>(?base37Collection, icrc7);

  let tokenOwner = testOwner;  // Replace with appropriate owner principal
  let spender = spender1;  // Replace with appropriate spender principal
  let token_ids = [1, 2, 3, 4, 5, 6, 7, 8 ,9, 10]; // Assuming tokens with IDs 1, 2, and 3 have been minted with known metadata
  
  let metadata1 = baseNFT;
  for(thisItem in token_ids.vals()){

    let #ok(metadata) = Properties.updatePropertiesShared(CandyConv.candySharedToProperties(baseNFT), [{
      name = "url";
      mode = #Set(#Text("https://example.com/" # Nat.toText(thisItem)))
    },
    ]) else return assert(false);

    let nft = icrc7.set_nfts<system>(testOwner,  [{
    token_id=thisItem;
    override=true;
    metadata = #Class(metadata);
    owner= ?(if(thisItem < 6) testOwnerAccount
        else {{owner = testCanister; subaccount = null}});
    memo=null;
    created_at_time=null;
  }],false);

  };

  // Create collection-wide approvals
  let approvalInfo = {
    approval_info = {
      memo = ?Text.encodeUtf8("Approval memo");
      expires_at = ?(init_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
      created_at_time = ?init_time : ?Nat64;  // Replace with appropriate creation timestamp
      from_subaccount = null;
      spender = spender;
    };
  };

  // Create collection-wide approvals
  let approvalInfo2 = {
    approval_info = {
      memo = ?Text.encodeUtf8("Approval memo");
      expires_at = ?(init_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
      created_at_time = ?init_time : ?Nat64;  // Replace with appropriate creation timestamp
      from_subaccount = null;
      spender = spender2;
    };
  };


  let #ok(?#Ok(approvalResponses)) = icrc37.approve_collection_transfer<system>(tokenOwner, approvalInfo) else return assert(false);
  D.print("approvalResponses" # debug_show(approvalResponses));

  let #ok(?#Ok(approvalResponses2)) = icrc37.approve_collection_transfer<system>(tokenOwner, approvalInfo2) else return assert(false);

  let #ok(tokenApprovalsAfterApproval) = icrc37.collection_approvals({owner = testOwner; subaccount = null}, null, null)else return assert(false);

  assert(tokenApprovalsAfterApproval.size() == 2);

  // Act: Revoke all collection-wide approvals for the specified account
  let revokeArgs = [{
    spender = ?spender;
    from_subaccount = null;
    memo = null;
    created_at_time = ?init_time;
  }];

  let revokeResponse = icrc37.revoke_collection_approvals<system>(tokenOwner, revokeArgs) else return assert(false);

  for (response in revokeResponse.vals()) {
    assert(
      (switch(response) {
        case (?#Ok(transaction_id)) true;
        case (_) false;
      })
    );  // "Revoke result indicates success for each token"
  };

  assert(not icrc37.is_approved([{spender; from_subaccount = null; token_id = 1;}])[0]);

  // Query for approvals of the entire collection after revocation
  let #ok(collectionApprovalsAfterRevocation) = icrc37.collection_approvals({owner = tokenOwner; subaccount = null;}, null, null) else return assert(false);

  // Assert: Check if there are no approvals remaining on the entire collection for the spender
  assert(collectionApprovalsAfterRevocation.size() == 1);  // "No collection approvals remaining after revocation"
});

testsys<system>("Revoke all collection approvals for an account", func<system>() {
  // Arrange: Set up the ICRC7 instance and approval parameters
   let icrc7 = getICRC7Class<system>(?baseCollection);
   let icrc37 = getICRC37Class<system>(?base37Collection, icrc7);

  let tokenOwner = testOwner;  // Replace with appropriate owner principal
  let spender = spender1;  // Replace with appropriate spender principal
  let token_ids = [1, 2, 3, 4, 5, 6, 7, 8 ,9, 10]; // Assuming tokens with IDs 1, 2, and 3 have been minted with known metadata
  
  let metadata1 = baseNFT;
  for(thisItem in token_ids.vals()){

    let #ok(metadata) = Properties.updatePropertiesShared(CandyConv.candySharedToProperties(baseNFT), [{
      name = "url";
      mode = #Set(#Text("https://example.com/" # Nat.toText(thisItem)))
    },]) else return assert(false);

    let nft = icrc7.set_nfts<system>(testOwner,  [{
    token_id= thisItem;
    override=true;
    metadata=#Class(metadata);
    owner= ?(if(thisItem < 6) testOwnerAccount
        else {{owner = testCanister; subaccount = null}});
   
    memo=null;
    created_at_time=null;
  }],false);

  };

  // Create collection-wide approvals
  let approvalInfo = {
    approval_info = {
      memo = ?Text.encodeUtf8("Approval memo");
      expires_at = ?(init_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
      created_at_time = ?init_time : ?Nat64;  // Replace with appropriate creation timestamp
      from_subaccount = null;
      spender = spender;
    };
  };

  // Create collection-wide approvals
  let approvalInfo2 = {
    approval_info = {
      memo = ?Text.encodeUtf8("Approval memo");
      expires_at = ?(init_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
      created_at_time = ?init_time : ?Nat64;  // Replace with appropriate creation timestamp
      from_subaccount = null;
      spender = spender2;
    };
  };

  assert(not icrc37.is_approved([{spender; from_subaccount = null; token_id = 1;}])[0]);
  assert(not icrc37.is_approved([{spender = spender2; from_subaccount = null; token_id = 1;}])[0]);

  let #ok(?#Ok(approvalResponses)) = icrc37.approve_collection_transfer<system>(tokenOwner, approvalInfo) else return assert(false);

  let #ok(?#Ok(approvalResponses2)) = icrc37.approve_collection_transfer<system>(tokenOwner, approvalInfo2)else return assert(false);

  let #ok(tokenApprovalsAfterApproval) = icrc37.collection_approvals({owner = testOwner; subaccount = null}, null, null)else return assert(false);

  assert(tokenApprovalsAfterApproval.size() == 2);

  // Act: Revoke all collection-wide approvals for the specified account
  let revokeArgs = [{
    spender = null;
    from_subaccount = null;
    created_at_time = ?init_time;
    memo = null;
  }];
  let revokeResponse = icrc37.revoke_collection_approvals(tokenOwner, revokeArgs) else return assert(false);

  for (response in revokeResponse.vals()) {
    assert(
      (switch(response) {
        case (?#Ok(transaction_id)) true;
        case (_) false;
      })
    );  // "Revoke result indicates success for each token"
  };

  assert(not icrc37.is_approved([{spender; from_subaccount = null; token_id = 1;}])[0]);

  // Query for approvals of the entire collection after revocation
  let #ok(collectionApprovalsAfterRevocation) = icrc37.collection_approvals({owner = tokenOwner; subaccount = null;}, null, null) else return assert(false);

  // Assert: Check if there are no approvals remaining on the entire collection for the spender
  assert(collectionApprovalsAfterRevocation.size() == 0);  // "No collection approvals remaining after revocation"
});


testsys<system>("Attempt to approve with duplicate or empty token ID arrays", func<system>() {
  // Arrange: Set up the ICRC7 instance and approval parameters
   let icrc7 = getICRC7Class<system>(?baseCollection);
   let icrc37 = getICRC37Class<system>(?base37Collection, icrc7);

  let tokenOwner = testOwner;  // Replace with appropriate owner principal
  let tokenIdsWithDuplicates = [1, 2, 3, 4, 5, 5];  // Token ID array with duplicate items
  let emptyTokenIds = [];  // Empty token ID array
  let spender = {owner = testCanister; subaccount = null};  // Replace with appropriate spender principal

  let tkid1 = Vec.new<Service.ApproveTokenArg>();
  for(thistoken in tokenIdsWithDuplicates.vals()){
    Vec.add(tkid1, {
      token_id = thistoken;
      approval_info = {
        memo = ?Text.encodeUtf8("Approval memo");
        expires_at = ?(test_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
        created_at_time = ?test_time : ?Nat64;  // Replace with appropriate creation timestamp
        
        from_subaccount = null;
        spender = spender;
      };
    });
  };

  // Act: Attempt approval requests with duplicate and empty token ID arrays
  let #ok(approvalResponsesWithDuplicates) = icrc37.approve_transfers<system>(tokenOwner, Vec.toArray(tkid1)) else return assert(false);

  let #err(approvalResponsesEmpty) = icrc37.approve_transfers<system>(tokenOwner, []) else return assert(false);

  D.print("resultImmutableUpdate" # debug_show(approvalResponsesWithDuplicates, approvalResponsesEmpty));

});

testsys<system>("Attempt to revoke approvals with duplicate or empty token ID arrays", func<system>() {
  // Arrange: Set up the ICRC7 instance and revoke approval parameters
   let icrc7 = getICRC7Class<system>(?baseCollection);
   let icrc37 = getICRC37Class<system>(?base37Collection, icrc7);

  let tokenOwner = testOwner;  // Replace with appropriate owner principal
  let tokenIdsWithDuplicates = [1, 2, 3, 4, 5, 5];  // Token ID array with duplicate items
  let spender = {owner = testCanister; subaccount = null};  // Replace with 
  let token_ids = [1, 2, 3, 4, 5, 6, 7, 8 ,9, 10]; // Assuming tokens with IDs 1, 2, and 3 have been minted with known metadata
  
  let metadata1 = baseNFT;
  for(thisItem in token_ids.vals()){

    let #ok(metadata) = Properties.updatePropertiesShared(CandyConv.candySharedToProperties(baseNFT), [{
      name = "url";
      mode = #Set(#Text("https://example.com/" # Nat.toText(thisItem)))
    }]) else return assert(false);

    let nft = icrc7.set_nfts<system>(testOwner,  [{
    token_id=thisItem;
    override=true;
    metadata= #Class(metadata);
    owner= ?(if(thisItem < 6) testOwnerAccount
        else {{owner = testCanister; subaccount = null}});
    memo=null;
    created_at_time=null;
  }],false);

  };

  let approvalInfo = Array.map<Nat, Service.ApproveTokenArg>([1,2,3,4,5], func(thisItem) : Service.ApproveTokenArg {
    {
      token_id = thisItem;
      approval_info = {
        memo = ?Text.encodeUtf8("Approval memo");
        expires_at = ?(init_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
        created_at_time = ?init_time : ?Nat64;  // Replace with appropriate creation timestamp
        from_subaccount = null;
        spender = spender;
      };
    };
  });

  // Act: Approve the spender for the specified token transfers
  let #ok(approvalResponses) = icrc37.approve_transfers<system>(tokenOwner,approvalInfo) else return assert(false);


  let emptyTokenIds = [];  // Empty token ID array
  
  let revokeInfo = {
    memo = ?Text.encodeUtf8("Revoke memo");
    created_at_time = ?test_time : ?Nat64;  // Replace with appropriate creation timestamp
    from_subaccount = null;
  };

  let tokenRequests = Array.map<Nat, Service.RevokeTokenApprovalArg>(tokenIdsWithDuplicates, func(tokenId) : Service.RevokeTokenApprovalArg {
    return {
      token_id=tokenId; 
      spender=?spender; 
      from_subaccount=null; 
      created_at_time=null; memo=null;};
  });

  
  // Act: Attempt revoke requests with duplicate and empty token ID arrays
  let revocationResponsesWithDuplicates = icrc37.revoke_tokens<system>(tokenOwner, tokenRequests);
  let revocationResponsesEmpty = icrc37.revoke_tokens<system>(tokenOwner, []);

  D.print("Revocation responses" # debug_show(revocationResponsesWithDuplicates, revocationResponsesEmpty));
});

