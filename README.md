# icrc30.mo

**Warning: ICRC30 has not been finalized. This is Beta software and should not be used in production until it has been reviewed, audited, and the standard finalized**


## Install
```
mops add icrc30.mo
```

## Usage
```motoko
import Icrc30Mo "mo:icrc30.mo";

## Initialization

This ICRC30 class uses a migration pattern as laid out in https://github.com/ZhenyaUsenko/motoko-migrations, but encapsulates the pattern in the Class+ pattern as described at https://forum.dfinity.org/t/writing-motoko-stable-libraries/21201 . As a result, when you insatiate the class you need to pass the stable memory state into the class:

```
stable var icrc30_migration_state = ICRC7.init(ICRC7.initialState() , #v0_1_0(#id), ?{
        max_approvals_per_token_or_collection = ?10;
        max_revoke_approvals = ?100;
        collection_approval_requires_token = ?true;
        max_approvals = null;
        settle_to_approvals = null;
        deployer = init_msg.caller;
      } : ICRC30.InitArgs;
    , init_msg.caller);

  let #v0_1_0(#data(icrc30_state_current)) = icrc30_migration_state;

  private var _icrc30 : ?ICRC30.ICRC30 = null;

  private func get_icrc30_environment() : ICRC30.Environment {
    {
      canister = get_canister;
      get_time = get_time;
      refresh_state = get_icrc30_state;
      icrc7 = icrc7(); //your icrc7 class
    };
  };

  func icrc30() : ICRC30.ICRC30 {
    switch(_icrc30){
      case(null){
        let initclass : ICRC30.ICRC30 = ICRC30.ICRC30(?icrc30_migration_state, Principal.fromActor(this), get_icrc30_environment());
        _icrc30 := ?initclass;
        initclass;
      };
      case(?val) val;
    };
  };

```

The above pattern will allow your class to call icrc30().XXXXX to easily access the stable state of your class and you will not have to worry about pre or post upgrade methods.

### Environment

The environment pattern lets you pass dynamic information about your environment to the class.

- get_canister - A function to retrieve the canister this class is running on
- get_time - A function to retrieve the current time to make testing easier
- refresh_state - A function to call to refresh the state of your class. useful in async environments where state may change after an await - provided for future compatibility.
- icrc7 - ICRC30 needs a reference to the ICRC7.mo class that runs your NFT canister.

### Input Init Args

  max_approvals_per_token_or_collection the maximum number of approvals that can be active for any account, defaults to 10,000;
  max_revoke_approvals - the maximum number of approvals that can be revoked at one time - defaults to the max_batch_update setting in your icrc7 class
  collection_approval_requires_token - will require that any user making a collection approval has a token in ownership;
  max_approvals - the max approvals allowed on the canister - defaults to 100,000;
  settle_to_approvals - the number of approvals that the cleanup will seek to reach if max_approvals is exceeded. Defaults to 99,750(So the default state is that 250 approvals(oldest first) will be removed if 100,001 approvals is reached).
  - deployer - the principal deploying, will be the owner of the collection;

  ## Deduplication

The class uses a Representational Independent Hash map to keep track of duplicate transactions within the permitted drift timeline.  The hash of the "tx" value is used such that provided memos and created_at_time will keep deduplication from triggering.