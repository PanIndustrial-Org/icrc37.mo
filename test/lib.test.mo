import ICRC30 "../src";
import ICRC7 "../../ICRC7/src";
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
import {test} "mo:test";

let testOwner = Principal.fromText("exoh6-2xmej-lux3z-phpkn-2i3sb-cvzfx-totbl-nzfcy-fxi7s-xiutq-mae");
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
  permitted_drift = null;
  deployer = testOwner;
};

let base30Collection = {
  max_approvals_per_token_or_collection = ?101;
  max_revoke_approvals = ?106;
  max_approvals = ?500;
  settle_to_approvals = ?450;
  collection_approval_requires_token = ?true;
  deployer = testOwner;
};

let baseNFT : CandyTypesLib.CandyShared = #Class([
  {immutable=false; name=ICRC7.token_property_owner_account; value = #Map([(ICRC7.token_property_owner_principal,#Blob(Principal.toBlob(testOwner)))]);},
  {immutable=false; name="url"; value = #Text("https://example.com/1");}
]);

let baseNFTWithSubAccount : CandyTypesLib.CandyShared = #Class([
  {immutable=false; name=ICRC7.token_property_owner_account; value = #Map(
    
    [(ICRC7.token_property_owner_principal, #Blob(Principal.toBlob(testOwner))),
     (ICRC7.token_property_owner_subaccount, #Blob(Blob.fromArray([1])))
    ]
    );},
  {immutable=false; name="url"; value = #Text("https://example.com/1");}
]);

func get_canister() : Principal{
  return testCanister;
};

let init_time = 1700925876000000000 : Nat64;
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

var icrc7_migration_state = ICRC7.init(ICRC7.initialState(), #v0_1_0(#id), ?baseCollection, testOwner);

var icrc30_migration_state = ICRC30.init(ICRC30.initialState(), #v0_1_0(#id), ?base30Collection, testOwner);

let #v0_1_0(#data(icrc7_state_current)) = icrc7_migration_state; 

let #v0_1_0(#data(icrc30_state_current)) = icrc30_migration_state; 

func get_icrc7_state(): ICRC7.CurrentState{
  return icrc7_state_current;
};

func get_icrc30_state(): ICRC30.CurrentState{
  return icrc30_state_current;
};

let base_environment= {
  canister = get_canister;
  get_time = get_time;
  refresh_state = get_icrc7_state;
  log = null;
  ledger = null;
};

func get_icrc30_environment(icrc7 : ICRC7.ICRC7) : ICRC30.Environment{

  {
    canister = get_canister;
    get_time = get_time;
    refresh_state = get_icrc30_state;
    icrc7 = icrc7;
  }
};

test("max_revoke_approvals can be initialized", func() {
  let icrc7 = ICRC7.ICRC7(?icrc7_migration_state, testCanister, base_environment);
  let icrc30 = ICRC30.ICRC30(?icrc30_migration_state, testCanister, get_icrc30_environment(icrc7));
  assert(icrc30.get_ledger_info().max_revoke_approvals == 106);
  ignore icrc30.update_ledger_info([#MaxRevokeApprovals(1000)]);
  assert(icrc30.get_ledger_info().max_revoke_approvals == 1000);
  ignore icrc30.update_ledger_info([#MaxApprovals(1001)]);
  assert(icrc30.get_ledger_info().max_approvals == 1001);
  ignore icrc30.update_ledger_info([#SettleToApprovals(991)]);
  assert(icrc30.get_ledger_info().settle_to_approvals == 991);
});

icrc7_migration_state := ICRC7.init(ICRC7.initialState(), #v0_1_0(#id), ?baseCollection, testOwner);
icrc30_migration_state := ICRC30.init(ICRC30.initialState(), #v0_1_0(#id), ?base30Collection, testOwner);

test("ICRC7 contract initializes with correct default state", func() {
  let icrc7 = ICRC7.ICRC7(?icrc7_migration_state, testCanister, base_environment);
  let icrc30 = ICRC30.ICRC30(?icrc30_migration_state, testCanister, get_icrc30_environment(icrc7));
  D.print(debug_show(icrc30.get_ledger_info()));
  
  assert(icrc30.get_ledger_info().max_approvals_per_token_or_collection == 101);
  assert(icrc30.get_ledger_info().max_revoke_approvals == 106);
  assert(icrc30.get_ledger_info().max_approvals == 500);
  assert(icrc30.get_ledger_info().settle_to_approvals == 450);
});

icrc7_migration_state := ICRC7.init(ICRC7.initialState(), #v0_1_0(#id), ?baseCollection, testOwner);
icrc30_migration_state := ICRC30.init(ICRC30.initialState(), #v0_1_0(#id), ?base30Collection, testOwner);

test("Approve another account for a set of token transfers", func() {
  // Arrange: Set up the ICRC7 instance and approval parameters
  let icrc7 = ICRC7.ICRC7(?icrc7_migration_state, testCanister, base_environment);
  let icrc30 = ICRC30.ICRC30(?icrc30_migration_state, testCanister, get_icrc30_environment(icrc7));

  let tokenOwner = testOwner;  // Replace with appropriate owner principal
  let spender = {owner = testCanister; subaccount = null};  // Replace with appropriate spender principal
  let approvedTokenIds = [1, 2, 3, 9, 10];  // Replace with appropriate token IDs
  let token_ids = [1, 2, 3, 4, 5, 6, 7, 8 ,9, 10]; // Assuming tokens with IDs 1, 2, and 3 have been minted with known metadata
  
  let metadata1 = baseNFT;
  for(thisItem in token_ids.vals()){

    let #ok(metadata) = Properties.updatePropertiesShared(CandyConv.candySharedToProperties(baseNFT), [{
      name = "url";
      mode = #Set(#Text("https://example.com/" # Nat.toText(thisItem)))
    }]) else return assert(false);

    let nft = icrc7.set_nfts(testOwner, {memo=null;created_at_time=null;tokens=[{token_id=thisItem;override=true;metadata=#Class(metadata);}]});

  };

  var approvalInfo = {
    memo = ?Text.encodeUtf8("Approval memo");
    expires_at = ?(init_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
    created_at_time = ?init_time : ?Nat64;  // Replace with appropriate creation timestamp
    from_subaccount = null;
    spender = spender;
  };

  // Act: Approve the spender for the specified token transfers
  let #ok(#Ok(approvalResponses)) = icrc30.approve_transfers(tokenOwner, approvedTokenIds, approvalInfo) else return assert(false);

  D.print("approvalResponses" # debug_show(approvalResponses));

  // Assert: Check if the approvals are correctly recorded
  assert(
    approvalResponses.size() == 5
  ); //"Correct number of approvals recorded"
  assert(
    approvalResponses[0].token_id == 1
  );//"First approval record for token with ID 1"
  assert(
    (switch(approvalResponses[0].approval_result) {
      case (#Ok(val)) true;
      case (_) return assert(false);
    }) == true
  );//"Approval result for token has id"

  // Test pagination of tokens owned by the account
  let approvedTokens1 = icrc30.is_approved(
    spender, 
    null, 
    3
  );
  
  // Assert: Check if approved for the item

  assert(approvedTokens1 == true)//"approval exists"
});

icrc7_migration_state := ICRC7.init(ICRC7.initialState(), #v0_1_0(#id), ?baseCollection, testOwner);
icrc30_migration_state := ICRC30.init(ICRC30.initialState(), #v0_1_0(#id), ?base30Collection, testOwner);

test("Check approval requests for expiry and creation times", func() {
  // Arrange: Set up the ICRC7 instance and approval parameters
  let icrc7 = ICRC7.ICRC7(?icrc7_migration_state, testCanister, base_environment);
  let icrc30 = ICRC30.ICRC30(?icrc30_migration_state, testCanister, get_icrc30_environment(icrc7));

  let tokenOwner = testOwner;  // Replace with appropriate owner principal
  let expiredTimestamp = test_time - 1000;  // Assume an expired timestamp
  let futureTimestamp = test_time + Nat64.fromNat(Int.abs(icrc7.get_ledger_info().permitted_drift)) + 1;  // Assume a future timestamp
  let oldTimestamp = test_time - Nat64.fromNat(Int.abs(icrc7.get_ledger_info().permitted_drift)) - 1;  // Assume a old timestamp

  let tokenIds = [1, 2];  // Replace with appropriate token IDs
  let spender = {owner = testCanister; subaccount = null};  // Replace with appropriate spender principal
  let invalidApprovalInfo1 = {
    memo = ?Text.encodeUtf8("Expired approval memo");
    expires_at = ?expiredTimestamp: ?Nat64;  // Set an expired expiry timestamp
    created_at_time = ?test_time : ?Nat64;  // Replace with appropriate creation timestamp
    from_subaccount = null;
    spender = spender;
  };

  let invalidApprovalInfo2 = {
    memo = ?Text.encodeUtf8("Future approval memo");
    expires_at = ?(test_time + one_day): ?Nat64;  // Set a future expiry timestamp
    created_at_time = ?futureTimestamp : ?Nat64;  // Replace with appropriate creation timestamp
    from_subaccount = null;
    spender = spender;
  };

  let invalidApprovalInfo3 = {
    memo = ?Text.encodeUtf8("Future approval memo");
    expires_at = ?(test_time + one_minute): ?Nat64;  // Set a future expiry timestamp
    created_at_time = ?oldTimestamp : ?Nat64;  // Replace with appropriate creation timestamp
    from_subaccount = null;
    spender = spender;
  };
  //D.print(debug_show(icrc30.approve_transfers(tokenOwner, tokenIds, invalidApprovalInfo1)));
  // Act: Attempt approval requests with expired and future timestamps
  let #err(approvalResponsesExpired) = icrc30.approve_transfers(tokenOwner, tokenIds, invalidApprovalInfo1) else return assert(false);
  let #ok(#Err(approvalResponsesFuture)) = icrc30.approve_transfers(tokenOwner, tokenIds, invalidApprovalInfo2) else return assert(false);

  let #ok(#Err(approvalResponsesOld)) = icrc30.approve_transfers(tokenOwner, tokenIds, invalidApprovalInfo3) else return assert(false);

  D.print("Approval results: " # debug_show(approvalResponsesExpired, approvalResponsesFuture, approvalResponsesOld));

});

icrc7_migration_state := ICRC7.init(ICRC7.initialState(), #v0_1_0(#id), ?baseCollection, testOwner);
icrc30_migration_state := ICRC30.init(ICRC30.initialState(), #v0_1_0(#id), ?base30Collection, testOwner);

test("Check approval errors for improper from_subaccount and non-existing token", func() {
  // Arrange: Set up the ICRC7 instance and approval parameters
  let icrc7 = ICRC7.ICRC7(?icrc7_migration_state, testCanister, base_environment);
  let icrc30 = ICRC30.ICRC30(?icrc30_migration_state, testCanister, get_icrc30_environment(icrc7));

  let token_id = 1;  // Assuming token with ID 1 exists
  let metadata = baseNFT;
  D.print("about to set" # debug_show(metadata));
  let nft = icrc7.set_nfts(testOwner, {memo=null;created_at_time=null;tokens=[{token_id=token_id;override=true;metadata=metadata;}]});


  let tokenOwner = testOwner;  // Replace with appropriate token owner principal
  let tokenWithSubaccount = 1;  // Replace with appropriate token ID that's held in a specific subaccount
  let nonExistingToken = 9999;  // Assume a non-existing token ID
  let improperApprovalInfo1 = {
    memo = ?Text.encodeUtf8("Improper subaccount approval memo");
    expires_at = null: ?Nat64;  // Set no expiration timestamp
    created_at_time = null: ?Nat64;  // Set no creation timestamp
    from_subaccount = ?Text.encodeUtf8("improper_subaccount");  // Set an improper subaccount
    spender = {owner = testCanister; subaccount = null};  // Replace with appropriate spender principal
  };
  let invalidApprovalInfo2 = {
    memo = ?Text.encodeUtf8("Non-existing token approval memo");
    expires_at = null: ?Nat64;  // Set no expiration timestamp
    created_at_time = null: ?Nat64;  // Set no creation timestamp
    from_subaccount = null;  // Set from_subaccount as null
    spender = {owner = testCanister; subaccount = null};  // Replace with appropriate spender principal
  };

  // Act: Attempt approval requests with an improper from_subaccount and a non-existing token
  let #ok(#Ok(approvalResponseImproperSubaccount)) = icrc30.approve_transfers(tokenOwner, [tokenWithSubaccount], improperApprovalInfo1) else return assert(false);
  let #ok(#Ok(approvalResponseNonExistingToken)) = icrc30.approve_transfers(tokenOwner, [nonExistingToken], invalidApprovalInfo2) else return assert(false);

  D.print("Improper approval results: " # debug_show(approvalResponseImproperSubaccount));
  D.print("Non-existing token approval results: " # debug_show(approvalResponseNonExistingToken));

  // Assert: Check if the expected errors are returned for an improper from_subaccount and non-existing token
  let #Err(improperSubaccountError) = approvalResponseImproperSubaccount[0].approval_result else return assert(false);
  let #Err(nonExistingTokenError) = approvalResponseNonExistingToken[0].approval_result else return assert(false);

  assert(
    improperSubaccountError == #Unauthorized
  );

  assert(
    nonExistingTokenError == #NonExistingTokenId
  );
});

icrc7_migration_state := ICRC7.init(ICRC7.initialState(), #v0_1_0(#id), ?baseCollection, testOwner);
icrc30_migration_state := ICRC30.init(ICRC30.initialState(), #v0_1_0(#id), ?base30Collection, testOwner);

test("Approve another account for all transfers in the collection and paginate query results", func() {
  // The ICRC7 class and base environment are set up from the provided framework
  let icrc7 = ICRC7.ICRC7(?icrc7_migration_state, testCanister, base_environment);
  let icrc30 = ICRC30.ICRC30(?icrc30_migration_state, testCanister, get_icrc30_environment(icrc7));

  let approvedSpender = spender1;

  let token_ids = [1, 2, 3, 4, 5, 6, 7, 8 ,9, 10]; // Assuming tokens with IDs 1, 2, and 3 have been minted with known metadata
  
  let metadata1 = baseNFT;
  for(thisItem in token_ids.vals()){

    let #ok(metadata) = Properties.updatePropertiesShared(CandyConv.candySharedToProperties(baseNFT), [{
      name = "url";
      mode = #Set(#Text("https://example.com/" # Nat.toText(thisItem)))
    },
    {
      name = ICRC7.token_property_owner_account;
      mode = #Set(#Map([(ICRC7.token_property_owner_principal,#Blob(Principal.toBlob(
        if(thisItem < 6) testOwner
        else testCanister)))]))
    }]) else return assert(false);

    let nft = icrc7.set_nfts(testOwner, {memo=null;created_at_time=null;tokens=[{token_id=thisItem;override=true;metadata=#Class(metadata);}]});

  };

  // Act: Approve another account for all transfers in the collection
  let approvalArgs = { 
    memo = null;
    expires_at = null;
    created_at_time = null;
    from_subaccount = null;
    spender = approvedSpender;
  }; 

  let approvalResponse = icrc30.approve_collection(testOwner, approvalArgs);
  let approvalResponse1 = icrc30.approve_collection(testOwner, {approvalArgs with spender = spender2});
  let approvalResponse2 = icrc30.approve_collection(testOwner, {approvalArgs with spender = spender3});
  let approvalResponse3 = icrc30.approve_collection(testOwner, {approvalArgs with spender = spender4});
  let approvalResponse4 = icrc30.approve_collection(testOwner, {approvalArgs with spender = spender5});

  D.print("Approval results: " # debug_show(approvalResponse, approvalResponse1, approvalResponse2, approvalResponse3, approvalResponse4));

  


  switch(approvalResponse, approvalResponse1, approvalResponse2, approvalResponse3, approvalResponse4){
    case(#ok(#Ok(_)),#ok(#Ok(_)),#ok(#Ok(_)),#ok(#Ok(_)),#ok(#Ok(_))){};
    case(_){
       return assert(false);
    };
  };

  

  // Pagination test
  let tokenIds = [1, 2, 3];  // Assume there are tokens 1, 2, 3 in the collection.
  var prevApprovalInfo : ?ICRC30.CollectionApproval = null;  // Initial page

  // Collect all approval responses
  let #ok(allApprovalResponses) = icrc30.get_collection_approvals({owner = testOwner; subaccount=null}, prevApprovalInfo, ?3) else return assert(false);

   D.print("Approval page1: " # debug_show(allApprovalResponses));

  if (Array.size(allApprovalResponses) == 3) {
    // Other tests here for successfully fetching all approvals on first paginated request
  } else {
    assert(false);  // Paginated request did not return all expected approvals
  };

  // Next  page test
  prevApprovalInfo := ?allApprovalResponses[2]; // Set the last approval as previous for the next paginated request
  let #ok(allApprovalResponses2) = icrc30.get_collection_approvals({owner = testOwner; subaccount=null}, prevApprovalInfo, ?3);

  D.print("Approval page2: " # debug_show(allApprovalResponses2));

  if (Array.size(allApprovalResponses2) == 2) {
    // All approvals fetched successfully from subsequent pages
  } else {
    assert(false);  // Subsequent paginated request did not return expected approvals
  }
});

icrc7_migration_state := ICRC7.init(ICRC7.initialState(), #v0_1_0(#id), ?baseCollection, testOwner);
icrc30_migration_state := ICRC30.init(ICRC30.initialState(), #v0_1_0(#id), ?base30Collection, testOwner);


test("Check collection approval requests for expiry and creation times", func() {
  let icrc7 = ICRC7.ICRC7(?icrc7_migration_state, testCanister, base_environment);
  let icrc30 = ICRC30.ICRC30(?icrc30_migration_state, testCanister, get_icrc30_environment(icrc7));

  let expiredTimestamp = test_time - 1000;  // Assume an expired timestamp
  let futureTimestamp = test_time + Nat64.fromNat(Int.abs(icrc7.get_ledger_info().permitted_drift)) + 1;  // Assume a future timestamp
  let oldTimestamp = test_time - Nat64.fromNat(Int.abs(icrc7.get_ledger_info().permitted_drift)) - 1;  // Assume an old timestamp
  
  let spender = {owner = testCanister; subaccount = null};  // Replace with appropriate spender principal
  let invalidApprovalInfo1 = {
    memo = ?Text.encodeUtf8("Expired approval memo");
    expires_at = ?expiredTimestamp: ?Nat64;  // Set an expired expiry timestamp
    created_at_time = ?test_time : ?Nat64;  // Replace with appropriate creation timestamp
    spender = spender1;
    from_subaccount = null;
  };

  let invalidApprovalInfo2 = {
    memo = ?Text.encodeUtf8("Future approval memo");
    expires_at = ?(test_time + one_day): ?Nat64;  // Set a future expiry timestamp
    created_at_time = ?futureTimestamp : ?Nat64;  // Replace with appropriate creation timestamp
    spender = spender1;
    from_subaccount = null;
  };

  let invalidApprovalInfo3 = {
    memo = ?Text.encodeUtf8("Future approval memo");
    expires_at = ?(test_time + one_minute): ?Nat64;  // Set a future expiry timestamp
    created_at_time = ?oldTimestamp : ?Nat64;  // Replace with appropriate creation timestamp
    spender = spender1;
    from_subaccount = null;
  };

  // Act: Attempt collection approval requests with expired and future timestamps
  let #err(approvalResponsesExpired) = icrc30.approve_collection(testOwner, invalidApprovalInfo1) else return assert(false);
  let #ok(#Err(approvalResponsesFuture)) = icrc30.approve_collection(testOwner, invalidApprovalInfo2) else return assert(false);
  let #ok(#Err(approvalResponsesOld)) = icrc30.approve_collection(testOwner, invalidApprovalInfo3) else return assert(false);

  D.print("Approval results: " # debug_show(approvalResponsesExpired, approvalResponsesFuture, approvalResponsesOld));

  
});




icrc7_migration_state := ICRC7.init(ICRC7.initialState(), #v0_1_0(#id), ?baseCollection, testOwner);
icrc30_migration_state := ICRC30.init(ICRC30.initialState(), #v0_1_0(#id), ?base30Collection, testOwner);

test("Check approval errors when owner doesn't own tokens in the collection", func() {
  // Arrange: Set up the ICRC7 instance and approval parameters
  let icrc7 = ICRC7.ICRC7(?icrc7_migration_state, testCanister, base_environment);
  let icrc30 = ICRC30.ICRC30(?icrc30_migration_state, testCanister, get_icrc30_environment(icrc7));

  let tokenOwner = testOwner;  // Replace with appropriate token owner principal
  
  let ownerWithoutTokens = spender1;  // Replace with an owner who doesn't own any tokens in the collection
  
  let approvalInfo = {
    memo = ?Text.encodeUtf8("Approval with no owned tokens memo");
    expires_at = null: ?Nat64;  // Set no expiration timestamp
    created_at_time = null: ?Nat64;  // Set no creation timestamp
    from_subaccount = null;  // Replace with an appropriate subaccount
    spender = spender2;
  };

  // Act: Attempt approval requests for non-existing token and owner without tokens
  let #ok(approvalResponseOwnerWithoutTokens) = icrc30.approve_collection(spender1.owner, approvalInfo) else return assert(false);
  
  D.print("Owner without tokens approval results: " # debug_show(approvalResponseOwnerWithoutTokens));

  // Assert: Check if the expected errors are returned for non-existing and owner without tokens scenarios
  let #Err(ownerWithoutTokensError) = approvalResponseOwnerWithoutTokens else return assert(false);

  assert(
    ownerWithoutTokensError == #Unauthorized
  );
});

icrc7_migration_state := ICRC7.init(ICRC7.initialState(), #v0_1_0(#id), ?baseCollection, testOwner);
icrc30_migration_state := ICRC30.init(ICRC30.initialState(), #v0_1_0(#id), ?base30Collection, testOwner);



test("Reject Approval Attempt by Unauthorized User", func() {
  // Arrange: Set up the ICRC7 instance, current test environment, and required variables
  let icrc7 = ICRC7.ICRC7(?icrc7_migration_state, testCanister, base_environment);
  let icrc30 = ICRC30.ICRC30(?icrc30_migration_state, testCanister, get_icrc30_environment(icrc7));

  let token_id = 1;  // Assuming token with ID 1 exists
  let metadata = baseNFT;
  D.print("about to set" # debug_show(metadata));
  let nft = icrc7.set_nfts(testOwner, {memo=null;created_at_time=null;tokens=[{token_id=token_id;override=true;metadata=metadata;}]});


  let unauthorizedOwner = spender1;  // Replace with an unauthorized owner principal
  let unauthorizedApprovalArgs = {
    from_subaccount = unauthorizedOwner.subaccount;
    spender  = spender2;
    memo = ?Text.encodeUtf8("Unauthorized transfer attempt");
    expires_at = null;
    //token_ids = [1];  // Replace with appropriate token ID for a token that the unauthorized owner owns
    created_at_time = ?init_time : ?Nat64;  // Replace with appropriate creation timestamp
  };

  // Act: Attempt to transfer a token by an unauthorized user
  let #ok(#Ok(approvalResponses)) = icrc30.approve_transfers(spender1.owner, [1],unauthorizedApprovalArgs) else return assert(false);

  // Assert: Check if the transfer attempt is rejected
  assert(
    approvalResponses.size() == 1
  ); //"Exactly one transfer response"
  assert(
    (switch(approvalResponses[0].approval_result) {
      case (#Err(err)) true;
      case (#Ok(val)) false;
    })
  ); //"Transfer attempt is rejected"
});

icrc7_migration_state := ICRC7.init(ICRC7.initialState(), #v0_1_0(#id), ?baseCollection, testOwner);
icrc30_migration_state := ICRC30.init(ICRC30.initialState(), #v0_1_0(#id), ?base30Collection, testOwner);


test("Transfer a token to another account after approval", func() {
  // ARRANGE: Set up the ICRC7 instance and required approvals
  let icrc7 = ICRC7.ICRC7(?icrc7_migration_state, testCanister, base_environment);
  let icrc30 = ICRC30.ICRC30(?icrc30_migration_state, testCanister, get_icrc30_environment(icrc7));

  let token_id = 1;  // Assuming token with ID 1 exists
  let metadata = baseNFT;
  D.print("about to set" # debug_show(metadata));
  let nft = icrc7.set_nfts(testOwner, {memo=null;created_at_time=null;tokens=[{token_id=token_id;override=true;metadata=metadata;}]});

  let tokenOwner = testOwner;  // Replace with appropriate owner principal
  let spender = spender1;  // Replace with appropriate spender principal
  let approvedTokenId = 1;  // Replace with the appropriate token ID
  let transferArgs = {
    from = {owner = tokenOwner; subaccount = null};  // Replace with the appropriate previous owner's principal
    to = {owner = testCanister; subaccount = null};  // Replace with the appropriate recipient's principal
    memo = ?Text.encodeUtf8("Transfer memo");  // Optionally set a memo
    created_at_time = ?test_time: ?Nat64;  // Replace with an appropriate creation timestamp
    spender_subaccount = spender1.subaccount;
    token_ids = [approvedTokenId];
  };

  // Prepare the approval information
  var approvalInfo = {
    memo = ?Text.encodeUtf8("Approval memo");
    expires_at = ?(test_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
    created_at_time = ?test_time : ?Nat64;  // Replace with appropriate creation timestamp
    from_subaccount = null;
    spender = spender;
  };

  // Create the approval for the token transfer
  let approvalResponses = icrc30.approve_transfers(tokenOwner, [approvedTokenId], approvalInfo);

  // ACT: Initiate the transfer of the approved token
  let #ok(#Ok(transferResponse)) = icrc30.transfer_from(spender.owner, transferArgs) else return assert(false);

  D.print("result is " # debug_show(approvalResponses, transferResponse));

  // ASSERT: Ensure that the transfer has been successful
  assert(
    (switch(transferResponse[0]) {
      case ({token_id =approvedTokenId; transfer_result = #Ok(trx_id)}) true;
      case (_) false;
    })
  );  //"Token transfer was successful"

  // Query for the owner of the token after transfer
  let ?ownerResponse = icrc7.get_token_owner(token_id);

    
    

     (switch(ownerResponse.account) {
      case (?val) {
        assert(val.owner == testCanister);
        assert(val.subaccount == null);
      };
      case (_) return assert(false);
    });

  //make sure the approval was cleared
  // Query for the owner of the token after transfer
  let approval_list_after = icrc30.get_token_approvals([approvedTokenId], null, null);

    (switch(approval_list_after) {
      case (#ok(list)) {
        assert(list.size() == 0);
      };
      case (_) return assert(false);
    });
});

icrc7_migration_state := ICRC7.init(ICRC7.initialState(), #v0_1_0(#id), ?baseCollection, testOwner);
icrc30_migration_state := ICRC30.init(ICRC30.initialState(), #v0_1_0(#id), ?base30Collection, testOwner);

test("Transfer a token to another account after collection approval", func() {
  // ARRANGE: Set up the ICRC7 instance and required approvals
  let icrc7 = ICRC7.ICRC7(?icrc7_migration_state, testCanister, base_environment);
  let icrc30 = ICRC30.ICRC30(?icrc30_migration_state, testCanister, get_icrc30_environment(icrc7));

  let token_id = 1;  // Assuming token with ID 1 exists
  let metadata = baseNFT;
  D.print("about to set" # debug_show(metadata));
  let nft = icrc7.set_nfts(testOwner, {memo=null;created_at_time=null;tokens=[{token_id=token_id;override=true;metadata=metadata;}]});

  let tokenOwner = testOwner;  // Replace with appropriate owner principal
  let spender = spender1;  // Replace with appropriate spender principal
  let approvedTokenId = 1;  // Replace with the appropriate token ID
  let transferArgs = {
    from = {owner = tokenOwner; subaccount = null};  // Replace with the appropriate previous owner's principal
    to = {owner = testCanister; subaccount = null};  // Replace with the appropriate recipient's principal
    memo = ?Text.encodeUtf8("Transfer memo");  // Optionally set a memo
    created_at_time = ?test_time: ?Nat64;  // Replace with an appropriate creation timestamp
    spender_subaccount = spender1.subaccount;
    token_ids = [approvedTokenId];
  };

  // Prepare the approval information
  var approvalInfo = {
    memo = ?Text.encodeUtf8("Approval memo");
    expires_at = ?(test_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
    created_at_time = ?test_time : ?Nat64;  // Replace with appropriate creation timestamp
    from_subaccount = null;
    spender = spender;
  };

  // Create the approval for the token transfer
  let approvalResponses = icrc30.approve_collection(tokenOwner, approvalInfo);

  assert(icrc30.is_approved(spender, null, 1));

  assert(not icrc30.is_approved(spender, ?Blob.fromArray([1]), 1));

  // ACT: Initiate the transfer of the approved token
  let #ok(#Ok(transferResponse)) = icrc30.transfer_from(spender.owner, transferArgs) else return assert(false);

  // ASSERT: Ensure that the transfer has been successful
  assert(
    (switch(transferResponse[0]) {
      case ({token_id = approvedTokenId; transfer_result = #Ok(trx_id)}) true;
      case (_) false;
    })
  );  //"Token transfer was successful"

  // Query for the owner of the token after transfer
  let ?ownerResponse = icrc7.get_token_owner(token_id);

    (switch(ownerResponse.account) {
      case (?val) {
        assert(val.owner == testCanister);
        assert(val.subaccount == null);
      };
      case (_) return assert(false);
    });
      
});

icrc7_migration_state := ICRC7.init(ICRC7.initialState(), #v0_1_0(#id), ?baseCollection, testOwner);
icrc30_migration_state := ICRC30.init(ICRC30.initialState(), #v0_1_0(#id), ?base30Collection, testOwner);

test("Clean up should limit number of approvals and log transactions", func() {
  // ARRANGE: Set up the ICRC7 instance and required approvals
  let icrc7 = ICRC7.ICRC7(?icrc7_migration_state, testCanister, base_environment);
  let icrc30 = ICRC30.ICRC30(?icrc30_migration_state, testCanister, get_icrc30_environment(icrc7));

  let metadata = baseNFT;
  D.print("about to set" # debug_show(metadata));
  

  let tokenOwner = testOwner;  // Replace with appropriate owner principal
  let spender = spender1;  // Replace with appropriate spender principal
  let approvedTokenId = 1;  // Replace with the appropriate token ID

  ignore icrc30.update_ledger_info([#MaxApprovals(8)]);
  ignore icrc30.update_ledger_info([#SettleToApprovals(4)]);
  
  for(thisItem in Iter.range(0,9)){
    let token_id = thisItem;  
    let metadata = baseNFT;
    D.print("about to set" # debug_show(metadata));
    let nft = icrc7.set_nfts(testOwner, {memo=null;created_at_time=null;tokens=[{token_id=token_id;override=true;metadata=metadata;}]});

    // Prepare the approval information
    var approvalInfo = {
      memo = ?Text.encodeUtf8("Approval memo");
      expires_at = ?(test_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
      created_at_time = ?test_time : ?Nat64;  // Replace with appropriate creation timestamp
      from_subaccount = null;
      spender = spender;
    };

    // Create the approval for the token transfer
    let approvalResponses = icrc30.approve_transfers(tokenOwner, [thisItem], approvalInfo);

  };

  assert(icrc30.is_approved(spender, null, 0) == false);
  assert(icrc30.is_approved(spender, null, 1) == false);
  assert(icrc30.is_approved(spender, null, 2) == false);
  assert(icrc30.is_approved(spender, null, 3) == false);

  assert(icrc30.is_approved(spender, null, 6) == true);
  assert(icrc30.is_approved(spender, null, 7) == true);
  assert(icrc30.is_approved(spender, null, 8) == true);
  assert(icrc30.is_approved(spender, null, 9) == true);

  D.print("the ledger:" # debug_show(ICRC7.Vec.toArray(icrc7.get_state().ledger)));
  assert(ICRC7.Vec.size(icrc7.get_state().ledger) > 10);

      
});

icrc7_migration_state := ICRC7.init(ICRC7.initialState(), #v0_1_0(#id), ?baseCollection, testOwner);
icrc30_migration_state := ICRC30.init(ICRC30.initialState(), #v0_1_0(#id), ?base30Collection, testOwner);

test("Too many approvals should trap", func() {
  // ARRANGE: Set up the ICRC7 instance and required approvals
  let icrc7 = ICRC7.ICRC7(?icrc7_migration_state, testCanister, base_environment);
  let icrc30 = ICRC30.ICRC30(?icrc30_migration_state, testCanister, get_icrc30_environment(icrc7));

  let metadata = baseNFT;
  D.print("about to set" # debug_show(metadata));

  let tokenOwner = testOwner;  // Replace with appropriate owner principal
  let spender = spender1;  // Replace with appropriate spender principal
  let approvedTokenId = 1;  // Replace with the appropriate token ID

  ignore icrc30.update_ledger_info([#MaxApprovalsPerTokenOrColletion(8)]);

  
  for(thisItem in Iter.range(0,9)){
    let token_id = thisItem;  
    let metadata = baseNFT;
    D.print("about to set" # debug_show((thisItem, metadata)));
    let nft = icrc7.set_nfts(testOwner, {memo=null;created_at_time=null;tokens=[{token_id=token_id;override=true;metadata=metadata;}]});

    // Prepare the approval information
    var approvalInfo = {
      memo = ?Text.encodeUtf8("Approval memo");
      expires_at = ?(test_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
      created_at_time = ?test_time : ?Nat64;  // Replace with appropriate creation timestamp
      from_subaccount = null;
      spender = spender;
    };

    let approvalResponses = icrc30.approve_transfers(tokenOwner, [thisItem], approvalInfo);
    D.print("approval result: " # debug_show(approvalResponses));
    // Create the approval for the token transfer
    if(thisItem < 8){
      let #ok(#Ok(approvalResponsesok)) = approvalResponses else return assert(false);
      D.print(debug_show(approvalResponses));
    } else {
      let #err(approvalResponseserr) = approvalResponses else return assert(false);
    }
  };
});

icrc7_migration_state := ICRC7.init(ICRC7.initialState(), #v0_1_0(#id), ?baseCollection, testOwner);
icrc30_migration_state := ICRC30.init(ICRC30.initialState(), #v0_1_0(#id), ?base30Collection, testOwner);

test("Transfer a token to another account after collection approval", func() {
  // ARRANGE: Set up the ICRC7 instance and required approvals
  let icrc7 = ICRC7.ICRC7(?icrc7_migration_state, testCanister, base_environment);
  let icrc30 = ICRC30.ICRC30(?icrc30_migration_state, testCanister, get_icrc30_environment(icrc7));

  let token_id = 1;  // Assuming token with ID 1 exists
  let metadata = baseNFT;
  D.print("about to set" # debug_show(metadata));
  let nft = icrc7.set_nfts(testOwner, {memo=null;created_at_time=null;tokens=[{token_id=token_id;override=true;metadata=metadata;}]});

  let tokenOwner = testOwner;  // Replace with appropriate owner principal
  let spender = spender1;  // Replace with appropriate spender principal
  let approvedTokenId = 1;  // Replace with the appropriate token ID
  let transferArgs = {
    from = {owner = tokenOwner; subaccount = null};  // Replace with the appropriate previous owner's principal
    to = {owner = testCanister; subaccount = null};  // Replace with the appropriate recipient's principal
    memo = ?Text.encodeUtf8("Transfer memo");  // Optionally set a memo
    created_at_time = ?test_time: ?Nat64;  // Replace with an appropriate creation timestamp
    spender_subaccount = spender1.subaccount;
    token_ids = [approvedTokenId];
  };

  // Prepare the approval information
  var approvalInfo = {
    memo = ?Text.encodeUtf8("Approval memo");
    expires_at = ?(test_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
    created_at_time = ?test_time : ?Nat64;  // Replace with appropriate creation timestamp
    from_subaccount = null;
    spender = spender;
  };

  // Create the approval for the token transfer
  let approvalResponses = icrc30.approve_collection(tokenOwner, approvalInfo);

  assert(icrc30.is_approved(spender, null, 1));

  assert(not icrc30.is_approved(spender, ?Blob.fromArray([1]), 1));

  // ACT: Initiate the transfer of the approved token
  let #ok(#Ok(transferResponse)) = icrc30.transfer_from(spender.owner, transferArgs) else return assert(false);

  // ASSERT: Ensure that the transfer has been successful
  assert(
    (switch(transferResponse[0]) {
      case ({token_id = approvedTokenId; transfer_result = #Ok(trx_id)}) true;
      case (_) false;
    })
  );  //"Token transfer was successful"

  // Query for the owner of the token after transfer
  let ?ownerResponse = icrc7.get_token_owner(token_id);

    (switch(ownerResponse.account) {
      case (?val) {
        assert(val.owner == testCanister);
        assert(val.subaccount == null);
      };
      case (_) return assert(false);
    });
      
});

icrc7_migration_state := ICRC7.init(ICRC7.initialState(), #v0_1_0(#id), ?baseCollection, testOwner);
icrc30_migration_state := ICRC30.init(ICRC30.initialState(), #v0_1_0(#id), ?base30Collection, testOwner);


test("Revoke a single approval on a token", func() {
  // Arrange: Set up the ICRC7 instance and approval parameters
  let icrc7 = ICRC7.ICRC7(?icrc7_migration_state, testCanister, base_environment);
  let icrc30 = ICRC30.ICRC30(?icrc30_migration_state, testCanister, get_icrc30_environment(icrc7));

  let tokenOwner = testOwner;  // Replace with appropriate owner principal
  let spender = spender1;  // Replace with appropriate spender principal
  let approvedTokenId = 1;  // Replace with the approved token’s ID

  let metadata = baseNFT;
  D.print("about to set" # debug_show(metadata));
  let nft = icrc7.set_nfts(testOwner, {memo=null;created_at_time=null;tokens=[{token_id=approvedTokenId;override=true;metadata=metadata;}]});
  
  // Create approval
  let approvalInfo = {
    memo = ?Text.encodeUtf8("Approval memo");
    expires_at = ?(init_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
    created_at_time = ?init_time : ?Nat64;  // Replace with appropriate creation timestamp
    from_subaccount = null;
    spender = spender1;
  };
  
  let approvalResponses = icrc30.approve_transfers(tokenOwner, [approvedTokenId], approvalInfo);

  // Create approval
  let approvalInfo2 = {
    memo = ?Text.encodeUtf8("Approval memo");
    expires_at = ?(init_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
    created_at_time = ?init_time : ?Nat64;  // Replace with appropriate creation timestamp
    from_subaccount = null;
    spender = spender2;
  };
  
  let approvalResponses2 = icrc30.approve_transfers(tokenOwner, [approvedTokenId], approvalInfo2);

  D.print("approvalResponses2" # debug_show(approvalResponses2));

  let #ok(tokenApprovalsAfterRevocation2) = icrc30.get_token_approvals([approvedTokenId], null, null) else return assert(false);

  D.print("approval list" # debug_show(tokenApprovalsAfterRevocation2));

  assert(tokenApprovalsAfterRevocation2.size() == 2);

  // Act: Revoke the single approval on the specified token
  let revokeArgs = {
    token_ids = [approvedTokenId];
    spender = ?spender1;
    from_subaccount = null;
    memo = null;
    created_at_time = ?init_time;
  };

  let #ok(#Ok(revokeResponse)) = icrc30.revoke_token_approvals(tokenOwner, revokeArgs) else return assert(false);
  D.print("revokeResponse" # debug_show(revokeResponse));

  // Assert: Check if the approval is correctly revoked and the ledger is updated
  assert(
    revokeResponse.size() == 1
  ); // "Single approval revoked"

  assert(
    (switch(revokeResponse[0].revoke_result) {
      case (#Ok(transaction_id)) true;
      case(_) false;
    }) 
  ); // "Revoke result indicates success"

  assert(not icrc30.is_approved(spender, null, 1));

  // Query for approvals of the token after revocation
  let #ok(tokenApprovalsAfterRevocation) = icrc30.get_token_approvals([approvedTokenId], null, null) else return assert(false);

  D.print("tokenApprovalsAfterRevocation" # debug_show(tokenApprovalsAfterRevocation));


  // Assert: Check if only one approval remains after revocation
  assert(tokenApprovalsAfterRevocation.size() == 1); // "Single approval remaining after revocation"
  assert(ICRC7.account_eq(tokenApprovalsAfterRevocation[0].approval_info.spender,spender2));
  


});

icrc7_migration_state := ICRC7.init(ICRC7.initialState(), #v0_1_0(#id), ?baseCollection, testOwner);
icrc30_migration_state := ICRC30.init(ICRC30.initialState(), #v0_1_0(#id), ?base30Collection, testOwner);

test("Revoke all approval on a token", func() {
  // Arrange: Set up the ICRC7 instance and approval parameters
  let icrc7 = ICRC7.ICRC7(?icrc7_migration_state, testCanister, base_environment);
  let icrc30 = ICRC30.ICRC30(?icrc30_migration_state, testCanister, get_icrc30_environment(icrc7));

  let tokenOwner = testOwner;  // Replace with appropriate owner principal
  let spender = spender1;  // Replace with appropriate spender principal
  let approvedTokenId = 1;  // Replace with the approved token’s ID

  let metadata = baseNFT;
  D.print("about to set" # debug_show(metadata));
  let nft = icrc7.set_nfts(testOwner, {memo=null;created_at_time=null;tokens=[{token_id=approvedTokenId;override=true;metadata=metadata;}]});
  
  // Create approval
  let approvalInfo = {
    memo = ?Text.encodeUtf8("Approval memo");
    expires_at = ?(init_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
    created_at_time = ?init_time : ?Nat64;  // Replace with appropriate creation timestamp
    from_subaccount = null;
    spender = spender1;
  };
  
  let approvalResponses = icrc30.approve_transfers(tokenOwner, [approvedTokenId], approvalInfo);

  // Create approval
  let approvalInfo2 = {
    memo = ?Text.encodeUtf8("Approval memo");
    expires_at = ?(init_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
    created_at_time = ?init_time : ?Nat64;  // Replace with appropriate creation timestamp
    from_subaccount = null;
    spender = spender2;
  };
  
  let approvalResponses2 = icrc30.approve_transfers(tokenOwner, [approvedTokenId], approvalInfo2);

  D.print("approvalResponses2" # debug_show(approvalResponses2));

  let #ok(tokenApprovalsAfterRevocation2) = icrc30.get_token_approvals([approvedTokenId], null, null) else return assert(false);

  D.print("approval list" # debug_show(tokenApprovalsAfterRevocation2));

  assert(tokenApprovalsAfterRevocation2.size() == 2);

  // Act: Revoke the single approval on the specified token
  let revokeArgs = {
    token_ids = [approvedTokenId];
    spender = null;
    from_subaccount = null;
    memo = null;
    created_at_time = ?init_time;
  };

  let #ok(#Ok(revokeResponse)) = icrc30.revoke_token_approvals(tokenOwner, revokeArgs)else return assert(false);
  D.print("revokeResponse" # debug_show(revokeResponse));

  // Assert: Check if the approval is correctly revoked and the ledger is updated
  assert(
    revokeResponse.size() == 2
  ); // "Single approval revoked"

  assert(not icrc30.is_approved(spender, null, 1));

  assert(
    (switch(revokeResponse[0].revoke_result) {
      case (#Ok(transaction_id)) true;
      case(_) false;
    }) 
  ); // "Revoke result indicates success"

  // Query for approvals of the token after revocation
  let #ok(tokenApprovalsAfterRevocation) = icrc30.get_token_approvals([approvedTokenId], null, null) else return assert(false);

  D.print("tokenApprovalsAfterRevocation" # debug_show(tokenApprovalsAfterRevocation));


  // Assert: Check if only one approval remains after revocation
  assert(tokenApprovalsAfterRevocation.size() == 0); // "Single approval remaining after revocation"

});

icrc7_migration_state := ICRC7.init(ICRC7.initialState(), #v0_1_0(#id), ?baseCollection, testOwner);
icrc30_migration_state := ICRC30.init(ICRC30.initialState(), #v0_1_0(#id), ?base30Collection, testOwner);


test("Revoke single collection approvals for an account", func() {
  // Arrange: Set up the ICRC7 instance and approval parameters
  let icrc7 = ICRC7.ICRC7(?icrc7_migration_state, testCanister, base_environment);
  let icrc30 = ICRC30.ICRC30(?icrc30_migration_state, testCanister, get_icrc30_environment(icrc7));

  let tokenOwner = testOwner;  // Replace with appropriate owner principal
  let spender = spender1;  // Replace with appropriate spender principal
  let token_ids = [1, 2, 3, 4, 5, 6, 7, 8 ,9, 10]; // Assuming tokens with IDs 1, 2, and 3 have been minted with known metadata
  
  let metadata1 = baseNFT;
  for(thisItem in token_ids.vals()){

    let #ok(metadata) = Properties.updatePropertiesShared(CandyConv.candySharedToProperties(baseNFT), [{
      name = "url";
      mode = #Set(#Text("https://example.com/" # Nat.toText(thisItem)))
    },
    {
      name = ICRC7.token_property_owner_account;
      mode = #Set(#Map([(ICRC7.token_property_owner_principal,#Blob(Principal.toBlob(
        if(thisItem < 6) testOwner
        else testCanister)))]))
    }]) else return assert(false);

    let nft = icrc7.set_nfts(testOwner, {memo=null;created_at_time=null;tokens=[{token_id=thisItem;override=true;metadata=#Class(metadata);}]});

  };

  // Create collection-wide approvals
  let approvalInfo = {
    memo = ?Text.encodeUtf8("Approval memo");
    expires_at = ?(init_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
    created_at_time = ?init_time : ?Nat64;  // Replace with appropriate creation timestamp
    from_subaccount = null;
    spender = spender;
  };

  // Create collection-wide approvals
  let approvalInfo2 = {
    memo = ?Text.encodeUtf8("Approval memo");
    expires_at = ?(init_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
    created_at_time = ?init_time : ?Nat64;  // Replace with appropriate creation timestamp
    from_subaccount = null;
    spender = spender2;
  };


  let #ok(#Ok(approvalResponses)) = icrc30.approve_collection(tokenOwner, approvalInfo) else return assert(false);
  D.print("approvalResponses" # debug_show(approvalResponses));


  assert(approvalResponses > 0);  // Ensure approval creation is successful

  let #ok(#Ok(approvalResponses2)) = icrc30.approve_collection(tokenOwner, approvalInfo2) else return assert(false);
  assert(approvalResponses2 > 1);  // Ensure approval creation is successful

  let #ok(tokenApprovalsAfterApproval) = icrc30.get_collection_approvals({owner = testOwner; subaccount = null}, null, null)else return assert(false);

  assert(tokenApprovalsAfterApproval.size() == 2);

  // Act: Revoke all collection-wide approvals for the specified account
  let revokeArgs = {
    spender = ?spender;
    from_subaccount = null;
    memo = null;
    created_at_time = ?init_time;
  };
  let #ok(#Ok(revokeResponse)) = icrc30.revoke_collection_approvals(tokenOwner, revokeArgs) else return assert(false);

  for (response in revokeResponse.vals()) {
    assert(
      (switch(response.revoke_result) {
        case (#Ok(transaction_id)) true;
        case (_) false;
      })
    );  // "Revoke result indicates success for each token"
  };

  assert(not icrc30.is_approved(spender, null, 1));

  // Query for approvals of the entire collection after revocation
  let #ok(collectionApprovalsAfterRevocation) = icrc30.get_collection_approvals({owner = tokenOwner; subaccount = null;}, null, null) else return assert(false);

  // Assert: Check if there are no approvals remaining on the entire collection for the spender
  assert(collectionApprovalsAfterRevocation.size() == 1);  // "No collection approvals remaining after revocation"
});

icrc7_migration_state := ICRC7.init(ICRC7.initialState(), #v0_1_0(#id), ?baseCollection, testOwner);
icrc30_migration_state := ICRC30.init(ICRC30.initialState(), #v0_1_0(#id), ?base30Collection, testOwner);

test("Revoke all collection approvals for an account", func() {
  // Arrange: Set up the ICRC7 instance and approval parameters
  let icrc7 = ICRC7.ICRC7(?icrc7_migration_state, testCanister, base_environment);
  let icrc30 = ICRC30.ICRC30(?icrc30_migration_state, testCanister, get_icrc30_environment(icrc7));

  let tokenOwner = testOwner;  // Replace with appropriate owner principal
  let spender = spender1;  // Replace with appropriate spender principal
  let token_ids = [1, 2, 3, 4, 5, 6, 7, 8 ,9, 10]; // Assuming tokens with IDs 1, 2, and 3 have been minted with known metadata
  
  let metadata1 = baseNFT;
  for(thisItem in token_ids.vals()){

    let #ok(metadata) = Properties.updatePropertiesShared(CandyConv.candySharedToProperties(baseNFT), [{
      name = "url";
      mode = #Set(#Text("https://example.com/" # Nat.toText(thisItem)))
    },
    {
      name = ICRC7.token_property_owner_account;
      mode = #Set(#Map([(ICRC7.token_property_owner_principal,#Blob(Principal.toBlob(
        if(thisItem < 6) testOwner
        else testCanister)))]))
    }]) else return assert(false);

    let nft = icrc7.set_nfts(testOwner, {memo=null;created_at_time=null;tokens=[{token_id=thisItem;override=true;metadata=#Class(metadata);}]});

  };

  // Create collection-wide approvals
  let approvalInfo = {
    memo = ?Text.encodeUtf8("Approval memo");
    expires_at = ?(init_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
    created_at_time = ?init_time : ?Nat64;  // Replace with appropriate creation timestamp
    from_subaccount = null;
    spender = spender;
  };

  // Create collection-wide approvals
  let approvalInfo2 = {
    memo = ?Text.encodeUtf8("Approval memo");
    expires_at = ?(init_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
    created_at_time = ?init_time : ?Nat64;  // Replace with appropriate creation timestamp
    from_subaccount = null;
    spender = spender2;
  };

  assert(not icrc30.is_approved(spender, null, 1));
  assert(not icrc30.is_approved(spender2, null, 1));

  let #ok(#Ok(approvalResponses)) = icrc30.approve_collection(tokenOwner, approvalInfo) else return assert(false);
  assert(approvalResponses > 0);  // Ensure approval creation is successful

  let #ok(#Ok(approvalResponses2)) = icrc30.approve_collection(tokenOwner, approvalInfo2)else return assert(false);
  assert(approvalResponses2 > 1);  // Ensure approval creation is successful

  let #ok(tokenApprovalsAfterApproval) = icrc30.get_collection_approvals({owner = testOwner; subaccount = null}, null, null)else return assert(false);

  assert(tokenApprovalsAfterApproval.size() == 2);

  // Act: Revoke all collection-wide approvals for the specified account
  let revokeArgs = {
    spender = null;
    from_subaccount = null;
    created_at_time = ?init_time;
    memo = null;
  };
  let #ok(#Ok(revokeResponse)) = icrc30.revoke_collection_approvals(tokenOwner, revokeArgs) else return assert(false);

  for (response in revokeResponse.vals()) {
    assert(
      (switch(response.revoke_result) {
        case (#Ok(transaction_id)) true;
        case (_) false;
      })
    );  // "Revoke result indicates success for each token"
  };

  assert(not icrc30.is_approved(spender, null, 1));

  // Query for approvals of the entire collection after revocation
  let #ok(collectionApprovalsAfterRevocation) = icrc30.get_collection_approvals({owner = tokenOwner; subaccount = null;}, null, null) else return assert(false);

  // Assert: Check if there are no approvals remaining on the entire collection for the spender
  assert(collectionApprovalsAfterRevocation.size() == 0);  // "No collection approvals remaining after revocation"
});

icrc7_migration_state := ICRC7.init(ICRC7.initialState(), #v0_1_0(#id), ?baseCollection, testOwner);
icrc30_migration_state := ICRC30.init(ICRC30.initialState(), #v0_1_0(#id), ?base30Collection, testOwner);

test("Attempt to approve with duplicate or empty token ID arrays", func() {
  // Arrange: Set up the ICRC7 instance and approval parameters
  let icrc7 = ICRC7.ICRC7(?icrc7_migration_state, testCanister, base_environment);
  let icrc30 = ICRC30.ICRC30(?icrc30_migration_state, testCanister, get_icrc30_environment(icrc7));

  let tokenOwner = testOwner;  // Replace with appropriate owner principal
  let tokenIdsWithDuplicates = [1, 2, 3, 4, 5, 5];  // Token ID array with duplicate items
  let emptyTokenIds = [];  // Empty token ID array
  let spender = {owner = testCanister; subaccount = null};  // Replace with appropriate spender principal
  let approvalInfo = {
    memo = ?Text.encodeUtf8("Approval memo");
    expires_at = ?(test_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
    created_at_time = ?test_time : ?Nat64;  // Replace with appropriate creation timestamp
    from_subaccount = null;
    spender = spender;
  };

  // Act: Attempt approval requests with duplicate and empty token ID arrays
  let #err(approvalResponsesWithDuplicates) = icrc30.approve_transfers(tokenOwner, tokenIdsWithDuplicates, approvalInfo) else return assert(false);
  let #err(approvalResponsesEmpty) = icrc30.approve_transfers(tokenOwner, emptyTokenIds, approvalInfo) else return assert(false);

  D.print("resultImmutableUpdate" # debug_show(approvalResponsesWithDuplicates, approvalResponsesEmpty));

});

icrc7_migration_state := ICRC7.init(ICRC7.initialState(), #v0_1_0(#id), ?baseCollection, testOwner);
icrc30_migration_state := ICRC30.init(ICRC30.initialState(), #v0_1_0(#id), ?base30Collection, testOwner);


test("Attempt to revoke approvals with duplicate or empty token ID arrays", func() {
  // Arrange: Set up the ICRC7 instance and revoke approval parameters
  let icrc7 = ICRC7.ICRC7(?icrc7_migration_state, testCanister, base_environment);
  let icrc30 = ICRC30.ICRC30(?icrc30_migration_state, testCanister, get_icrc30_environment(icrc7));

  let tokenOwner = testOwner;  // Replace with appropriate owner principal
  let tokenIdsWithDuplicates = [1, 2, 3, 4, 5, 5];  // Token ID array with duplicate items
  let spender = {owner = testCanister; subaccount = null};  // Replace with 
  let token_ids = [1, 2, 3, 4, 5, 6, 7, 8 ,9, 10]; // Assuming tokens with IDs 1, 2, and 3 have been minted with known metadata
  
  let metadata1 = baseNFT;
  for(thisItem in token_ids.vals()){

    let #ok(metadata) = Properties.updatePropertiesShared(CandyConv.candySharedToProperties(baseNFT), [{
      name = "url";
      mode = #Set(#Text("https://example.com/" # Nat.toText(thisItem)))
    },
    {
      name = ICRC7.token_property_owner_account;
      mode = #Set(#Map([(ICRC7.token_property_owner_principal,#Blob(Principal.toBlob(
        if(thisItem < 6) testOwner
        else testCanister)))]))
    }]) else return assert(false);

    let nft = icrc7.set_nfts(testOwner, {memo=null;created_at_time=null;tokens=[{token_id=thisItem;override=true;metadata=#Class(metadata);}]});

  };

  var approvalInfo = {
    memo = ?Text.encodeUtf8("Approval memo");
    expires_at = ?(init_time + one_minute): ?Nat64;  // Replace with appropriate expiry timestamp
    created_at_time = ?init_time : ?Nat64;  // Replace with appropriate creation timestamp
    from_subaccount = null;
    spender = spender;
  };

  // Act: Approve the spender for the specified token transfers
  let #ok(approvalResponses) = icrc30.approve_transfers(tokenOwner, [1,2,3,4,5], approvalInfo) else return assert(false);


  let emptyTokenIds = [];  // Empty token ID array
  
  let revokeInfo = {
    memo = ?Text.encodeUtf8("Revoke memo");
    created_at_time = ?test_time : ?Nat64;  // Replace with appropriate creation timestamp
    from_subaccount = null;
  };

  // Act: Attempt revoke requests with duplicate and empty token ID arrays
  let revocationResponsesWithDuplicates = icrc30.revoke_token_approvals(tokenOwner, {token_ids=tokenIdsWithDuplicates; spender=?spender; from_subaccount=null; created_at_time=null; memo=null;});
  let revocationResponsesEmpty = icrc30.revoke_token_approvals(tokenOwner, {token_ids=emptyTokenIds; spender=?spender; from_subaccount=null; created_at_time=null; memo=null;});

  D.print("Revocation responses" # debug_show(revocationResponsesWithDuplicates, revocationResponsesEmpty));
});

