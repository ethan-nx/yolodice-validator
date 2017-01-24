YOLOdice bet validator
======================

[YOLOdice](https://yolodice.com) is a simple online Bitcoin game you can play against the house. In heart of it lies a pseudorandom number generator that returns bet results used to determine if bets placed by players win or lose. Players can independently verify if the bets are "fair".

This Ruby utility let's you validate the following:

* if the seed hash matches the seed,
* if your bets on YOLOdice have been generated according to the *Provably fair* algorithm,
* if the profit for each bet has been calculated properly.

For more information about the algorithms used in YOLOdice, check out our [Frequently Asked Questions](https://yolodice.dev/#faq/provably-fair).

## Installation

The validator does not depend on any gems. It's only necessare to get the validator's code to use it. Alternatively you can install it as a gem. It will then install it's own executable, `yolodice-validator` in the system.

### Using a gem from RubyGems

    gem install yolodice-validator

### By cloning the git repo

    git clone https://github.com/ethan-nx/yolodice-validator.git

This will clone the whole repo.

### Download the ZIP archive and unpack it

Github provides a ZIP archive of the most current revision of the code. Find it here: https://github.com/ethan-nx/yolodice-validator/archive/master.zip


## Usage

If you installed the utility as a gem in order to run the code simply type:

    yolodice_validator DUMP_FILE

If you cloned the git repo or downloaded the source, try this:

    ruby lib/yolodice-validator.rb DUMP_FILE

You can get the `DUMP_FILE` by visiting your YOLOdice account and entering the [Seeds panel](https://yolodice.com/#seeds). Then click on any archived seed, a pop-up will appear. Click "Verify bets" button and download the generated dump. That's the file you need.

Example usage:


    $ yolodice_validator ~/Downloads/seed_dump_2.csv
    Seed seems OK, validating individual bets
    .................................................
    All bets verified OK

Example check of a seed that contains invalid data:

    $ yolodice_validator ~/Downloads/seed_dump_2.csv
    MISMATCH: secret_hashed_hex, in file: e93e86fd421942a319403738e7dcdbe1f1bf3371ae43d26ff6768d97c2c948d0, calculated: e93e86fd421942a319409738e7dcdbe1f1bf3371ae43d26ff6768d97c2c948d0
    Seed data is not valid, checking bets anyway.
    MISMATCH: bet 6 result, in file: 723763, calculated: 729763
    MISMATCH: bet 7 result, in file: 899308, calculated: 499308
    MISMATCH: bet 7 profit, in file: 2, calculated: 0
    .................................................
    4 errors found.

