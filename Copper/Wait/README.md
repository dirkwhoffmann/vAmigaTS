## Objective

This test suite verfies particular aspects of the WAIT command.

#### copwait1 and copwait2

Checks the behaviour of the WAIT command with waiting positions near it's own execution cycle. 

#### copwait3 and copwait4

Same as copwait1 and copwait2 with a fifth bitplane enabled.

#### copwait5 and copwait6

Checks the WAIT command with horizontal positions around 0 and $E2, respectively. 

#### copwait7 and copwait8

Same as copwait7 and copwait8 with a fifth bitplane enabled.

#### mask1

Applies the WAIT command with varying comparison masks

#### crossing1 and crossing2

Tries to cross the vertical boundary. crossing1 triggers at $ffdb which is too early. crossing2 triggers at $ffdd which is just in time to cross.


Dirk Hoffmann, 2019