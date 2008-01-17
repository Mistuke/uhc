%include lhs2TeX.fmt
%include forSubText.fmt

%{

%format < 		= "{\langle}"
%format > 		= "{\rangle}"
\label{ag-primer}

\paragraph{Haskell and Attribute Grammars (AG).}
Attribute grammars can be mapped onto functional programs
\cite{kuiper86ag-fp,johnsson87attr-as-fun,bird84circ-traverse}.
Vice versa, the class of functional programs
(catamorphisms \cite{swierstra99comb-lang})
mapped onto can be described by attribute grammars.
The AG system exploits this correspondence by providing a notation (attribute grammar) for
computations over trees
which additionally allows
program fragments to be described separately.
The AG compiler gathers these fragments, combines these fragments, and generates a corresponding
Haskell program.

In this AG tutorial we start with a small example Haskell program (of the right form) to
show how the computation described by this program can be expressed in the AG notation and how
the resulting Haskell program generated by the AG compiler can be used.
The `repmin' problem \cite{bird84circ-traverse} is used for this purpose.
A second example describing a `pocket calculator' (that is, expressions) focusses on
more advanced features and typical AG usage patterns.

\paragraph{Repmin a la Haskell.}
Repmin stands for ``replacing the integer valued leaves of a tree by the minimal integer value found in the leaves''.
The solution to this problem requires two passes over a tree structure,
computing the miminum and computing
a new tree with the minimum as its leaves respectively.
It is often used as the typical example of a circular program which lends itself well to be described by the
AG notation.
When described in Haskell it is expressed as a computation over a tree structure:

\chunkCmdUse{RepminHS.1.data}

The computation itself simultaneously computes the minimum of all integers found in the leaves of the tree and
the new tree with this minimum value.
The result is returned as a tuple computed by function |r|:

\savecolumns
\chunkCmdUse{RepminHS.1.repmin}
\restorecolumns
\chunkCmdUse{RepminHS.1.repminBin}

We can use this function in some setting, for example:

\chunkCmdUse{RepminHS.1.main}

The resulting program produces the following output:

\begin{TT}
Tree_Bin (Tree_Leaf 3) (Tree_Bin (Tree_Leaf 3) (Tree_Leaf 3))
\end{TT}

The computation of the new tree requires the minimum.
This minimum is passed as a parameter |m| to |r| at the root of the tree by extracting it from the result of |r|.
The result tuple of the invocation |r t tmin|
depends on itself via the minimum |tmin| so it would seem we have a cyclic definition.
However, the real dependency is not on the tupled result of |r| but on its elements because
it is the element |tmin| of the result tuple which is passed back and not the tuple itself.
The elements are not cyclically dependent so Haskell's laziness prevents
a too eager computation of the elements of the tuple which might otherwise have caused an infinite loop during
execution.
Note that we have two more or less independent computations that both follow
the tree structure,
and a weak interaction, when passing the |tmin| value back in the tree.

\paragraph{Repmin a la AG.}
The structure of |repmin| is similar to the structure required by a compiler.
A compiler performs several computations
over an \IxAsDef{abstract syntax tree} (\IxAsDef{AST}), for example for computing its type
and code.
This corresponds to the |Tree| structure used by |repmin| and the tupled results.
In the context of attribute grammars the elements of this tuple are called \IxAsDef{attribute}'s.
Occasionaly the word \IxAsDef{aspect} is used as well, but an aspect may also refer to a group of attributes associated with
one particular feature of the AST, language or problem at hand.

Result elements are called \IxAsDef{synthesized} attributes.
On the other hand,
a compiler may also require information that becomes available at higher nodes in an AST to be available at lower nodes in an AST.
The |m| parameter passed to |r| in |repmin| is an example of this situation.
In the context of attribute grammars this is called an \IxAsDef{inherited} \IxAsDef{attribute}.

Using AG notation we first define the AST corresponding to our problem
(for which the complete compilable solution is given in \figRef{ag-primer-full-repmin}):

\chunkCmdUse{RepminAG.1.data1}

\begin{Figure}{Full AG specification of repmin}{ag-primer-full-repmin}
\savecolumns
\chunkCmdUse{RepminAG.1.data1}
\restorecolumns
\chunkCmdUse{RepminAG.1.min}
\restorecolumns
\chunkCmdUse{RepminAG.1.repmin}
\restorecolumns
\chunkCmdUse{RepminAG.1.copyRule1}
\restorecolumns
\chunkCmdUse{RepminAG.1.repminBin}
\restorecolumns
\chunkCmdUse{RepminAG.1.data2}
\restorecolumns
\chunkCmdUse{RepminAG.1.repminroot}
\restorecolumns
\chunkCmdUse{RepminAG.1.tree}
\restorecolumns
\chunkCmdUse{RepminAG.1.copyRule2}
\restorecolumns
\chunkCmdUse{RepminAG.1.treeRoot}
\restorecolumns
\chunkCmdUse{RepminAG.1.show}
\restorecolumns
\chunkCmdUse{RepminAG.1.main}
\end{Figure}



The |DATA| keyword is used to introduce the equivalent of Haskell's |data| type.
A |DATA <node>| defines a \IxAsDef{node} |<node>| (or \IxAsDef{nonterminal})
of an AST.
Its alternatives, enumerated one by one after the vertical bar | || |, are called
\IxAsDef{variants}, \IxAsDef{productions}.
The term \IxAsDef{constructor} is occasionally used to stress the similarity with
its Haskell counterpart.
Each variant has members,
called \IxAsDef{children} if they refer to other nodes of the AST and \IxAsDef{fields} otherwise.
Each child and field has a name (before the colon) and a type (after the colon).
The type may be either another |DATA| node (if a child) or a monomorphic Haskell type (if a field), delimited by curly braces.
The curly braces may be omitted if the Haskell type is a single identifier.
For example, the |DATA| definition for the repmin problem introduces a node (nonterminal) |Tree|,
with variants (productions) |Leaf| and |Bin|.
A |Bin| has children |lt| and |rt| of type |Tree|.
A |Leaf| has no children but contains only a field |int| holding a Haskell |Int| value.

The keyword |ATTR| is used to declare an attribute for a node, for instance the synthesized attribute |min|:

\chunkCmdUse{RepminAG.1.min}

A synthesized attribute is declared for the node after |ATTR|.
Multiple declarations of the same attribute for different nonterminals
can be grouped on one line by enumerating the nonterminals after the |ATTR| keyword, separated by whitespace.
The attribute declaration is placed inside the square brackets at one or more of three different possible places.
All attributes before the first vertical bar | || | are inherited, after the last bar synthesized, and in between both
inherited and synthesized.
For example, attribute |min| is a result and therefore positioned as a synthesized attribute, after the last bar.

Rules relating an attribute to its value are introduced using the keyword |SEM|.
For each production we distinguish a set of input attributes, consisting of the synthesized attributes of the children
referred to by |@ <child> . <attr>| and the inherited attributes of the parent referred to by |@lhs. <attr>|.
For each output attribute we need a rule that expresses its value in terms of input attributes and fields.

%if False
Rules relate attributes from a \IxAsDef{parent} node to the attributes of its
\IxAsDef{child} nodes.
Synthesized attributes travel upwards in the AST and must be defined for a parent in terms
of inherited attributes of the parent or synthesized attributes of the children.
Inherited attributes travel downwards in the AST and must be defined for each child for which it
has been declared.
Inherited attributes are defined in terms of inherited attributes of the parent of synthesized attributes
of neighbouring children.
%endif

The computation for a synthesized attribute for a node
has to be defined for each variant individually as
it usually will differ between variants.
Each rule is of the form

\begin{code}
| <variant> ^^^ <node> . <attr> = <Haskell expr>
\end{code}

If multiple rules are declared for a |<variant>| of a node, the |<variant>| part may be shared.
The same holds for multiple rules for a child (or |lhs|) of a |<variant>|, the child (or |lhs|) may then be shared.

The text representing the computation for an attribute has to be a Haskell expression
and will end up almost unmodified in the generated program,
without any form of checking.
Only attribute and field references, starting with a |@|, have meaning to the AG system.
The text, possibly stretching over multiple lines,
has to be indented at least as far as its first line.
Otherwise it is to be delimited by curly braces.

The basic form of an attribute reference
is |@ <node> . <attr>| referring to a synthesized attribute |<attr>| of child node |<node>|.
For example, |@lt.min| refers to the synthesized attribute |min| of child |lt| of the |Bin| variant of node |Tree|.

The |<node> .| part of |@ <node> . <attr>| may be omitted.
For example, |min| for the |Leaf| alternative is defined in terms of |@int|.
In that case |@ <attr>| refers to a locally (to a variant for a node) declared attribute, or to
the field with the same name as defined in the |DATA| definition for that variant.
This is the case for the |Leaf| variant's |int|.
We postpone the discussion of locally declared attributes.

The minimum value of |repmin| passed as a parameter corresponds to an inherited attribute |rmin|:

\chunkCmdUse{RepminAG.1.repmin}

%if False
An inherited attribute is referred to by |@lhs. <attr>|; similar to |@ <node> . <attr>| for synthesized attributes
but with |<node> == lhs|.
The rule for an inherited attribute is also the other way around compared to a synthesized attribute.
In
\begin{code}
| <variant> ^^^ <node> . <attr> = <Haskell expr>
\end{code}
|<node>| must now explicitly refer to a child of which an attribute has to be given a value
to be passed further down the AST.
For the |rmin| attribute this is the |lt| as well as the |rt| child of the |Bin| variant of node |Tree|.
%endif

The value of |rmin| is straightforwardly copied to its children.
This ``simply copy'' behavior occurs so often that we may omit its specification.
The AG system uses so called copy rules to automically generate code for copying
if the value of an attribute is not specified explicitly.
This is to prevent program clutter and thus allows the programmer to focus on programming
the exception instead of the usual.
We will come back to this later; for now it suffices to mention that all the rules for |rmin|
might as well have been omitted.

The original |repmin| function did pass the minimum value coming out |r| back into |r| itself.
This did happen at the top of the tree.
Similarly we define a |Root| node sitting on top of a |Tree|:

\chunkCmdUse{RepminAG.1.data2}

At the root the |min| attribute is passed back into the tree via attribute |rmin|:

\chunkCmdUse{RepminAG.1.repminroot}

The value of |rmin| is used to construct a new tree:

\savecolumns
\chunkCmdUse{RepminAG.1.tree}
\restorecolumns
\chunkCmdUse{RepminAG.1.treeRoot}

For each |DATA| the AG compiler generates a corresponding Haskell |data| type declaration.
For each node |<node>| a data type with the same name |<node>| is generated.
Since Haskell requires all constructors to
be unique, each constructor of the data type gets a name of the form |<node>_<variant>|.

In our example the constructed tree is returned as the one and only attribute of |Root|.
It can be shown if we tell the AG compiler to make the generated data type an
instance of the |Show| class:

\chunkCmdUse{RepminAG.1.show}

Similarly to the Haskell version of |repmin| we can now show the result of the attribute computation as a plain Haskell value
by using the function |sem_Root| generated by the AG compiler:

\chunkCmdUse{RepminAG.1.main}

Because this part is Haskell code it has to be delimited by curly braces, indicating that
the AG compiler should copy it unchanged into the generated Haskell program.

In order to understand what is happening here,
we take a look at the generated Haskell code.
For the above example the following code will be generated (edited to remove clutter):

\begin{TT}
data Root = Root_Root (Tree)
-- semantic domain
type T_Root = ( (Tree))
-- cata
sem_Root :: (Root) -> (T_Root)
sem_Root ((Root_Root (_tree)))
  = (sem_Root_Root ((sem_Tree (_tree))))
sem_Root_Root :: (T_Tree) -> (T_Root)
sem_Root_Root (tree_) =
    let ( _treeImin,_treeItree) = (tree_ (_treeOrmin))
        (_treeOrmin) = _treeImin
        (_lhsOtree) = _treeItree
    in  ( _lhsOtree)

data Tree = Tree_Bin (Tree) (Tree)
          | Tree_Leaf (Int)
          deriving ( Show)
-- semantic domain
type T_Tree = (Int) -> ( (Int),(Tree))
-- cata
sem_Tree :: (Tree) -> (T_Tree)
sem_Tree ((Tree_Bin (_lt) (_rt)))
  = (sem_Tree_Bin ((sem_Tree (_lt))) ((sem_Tree (_rt))))
sem_Tree ((Tree_Leaf (_int))) = (sem_Tree_Leaf (_int))
sem_Tree_Bin :: (T_Tree) -> (T_Tree) -> (T_Tree)
sem_Tree_Bin (lt_) (rt_) =
    \ _lhsIrmin ->
        let ( _ltImin,_ltItree) = (lt_ (_ltOrmin))
            ( _rtImin,_rtItree) = (rt_ (_rtOrmin))
            (_lhsOmin) = _ltImin `min` _rtImin
            (_rtOrmin) = _lhsIrmin
            (_ltOrmin) = _lhsIrmin
            (_lhsOtree) = Tree_Bin   _ltItree _rtItree
        in  ( _lhsOmin,_lhsOtree)
sem_Tree_Leaf :: (Int) -> (T_Tree)
sem_Tree_Leaf (int_) =
    \ _lhsIrmin ->
        let (_lhsOmin) = int_
            (_lhsOtree) = Tree_Leaf  _lhsIrmin
        in  ( _lhsOmin,_lhsOtree)
\end{TT}

In general, generated code is not the most pleasant\footnote{In addition, because generated code can be generated differently,
one cannot count on it being generated in a specific way.
Such is the case here too, this part of the AG implementation may well change in the future.}
of prose to look at, but we will have to use the generated
functions in order to access the AG computations of attributes from the Haskell world.
The following observations should be kept in mind when doing so:
\begin{itemize}
\item
For node |<node>| also a type |T_<node>| is generated, describing the function type
that maps inherited to synthesized attributes.
This type corresponds one-to-one to the attributes defined for |<node>|: inherited attributes to parameters, synthesized attributes
to elements of the result tuple (or single type if exactly one synthesized attribute is defined).
\item
Computation of attribute values is done by semantic functions with a name of the form |sem_<node>_<variant>|.
These functions have exactly the same type as their constructor counterpart of the generated data type.
The only difference lies in the parameters which are of the same type as their constructor counterpart, but
prefixed with |T_|.
For example, data constructor |Tree_Bin :: Tree -> Tree -> Tree| corresponds to the semantic function
|sem_Tree_Bin :: (T_Tree) -> (T_Tree) -> (T_Tree)|.
\item
A mapping from the Haskell |data| type to the corresponding semantic function is available with
the name |sem_<node>|.
\end{itemize}

In the Haskell world one now can follow different routes to compute the attributes:
\begin{itemize}
\item
First construct a Haskell value of type |<node>|, then apply |sem_<node>| to this value and the
additionally required inherited attributes values.
The given function |main| from AG variant of repmin takes this approach.
\item
Circumvent the construction of Haskell values of type |<node>| by using the semantic functions |sem_<node>_<variant>|
directly when building the AST instead of the data constructor |<node>_<variant>|
(This technique is called deforestation \cite{wadler90deforest}.).
\end{itemize}

In both cases a tuple holding all synthesized attributes is returned.
Elements in the tuple are sorted lexicographically on attribute name,
but it still is awkward to extract an attribute via pattern matching because
the size of the tuple and position of elements changes with adding and renaming attributes.
For now, this is not a problem as |sem_Root| will only return one value, a |Tree|.
Later we will see the use of wrapper functions to pass inherited attributes and extract synthesized attributes
via additional wrapper data types holding attributes in labeled fields.

\paragraph{Parsing directly to semantic functions.}
The given |main| function uses the first approach: construct a |Tree|, wrap it inside a |Root|, and
apply |sem_Root| to it.
The following example takes the second approach; it parses some input text describing the structure of a tree and
directly invokes the semantic functions:

\chunkCmdUse{RepminAG.2.parser}

The parser recognises the letter '@B@' as a |Bin| alternative and a single digit as a |Leaf|.
\FigRef{parser-combinators} gives an overview of the parser combinators which are used \cite{uust04www}.
The parser is invoked from an alternative implementation of |main|:

\chunkCmdUse{RepminAG.2.main}

We will not discuss this alternative further nor will we discuss this particular variant of
parser combinators.
However, this approach is taken in the rest of \thispaper\ wherever parsing is required.

\begin{Figure}{Parser combinators}{parser-combinators}
\begin{tabular}{lll}
\ParserCombTableHead
\ParserCombTableA
\ParserCombTableB
\end{tabular}
\end{Figure}

\paragraph{More features and typical usage: a pocket calculator.}
We will continue with looking at a more complex example, a pocket calculator which accepts expressions.
The calculator prints a pretty printed version of the entered expression, its computed value and some statistics
(the number of additions performed).
An interactive terminal session of the pocket calculator looks as follows:

\begin{TT}
$ build/bin/expr
Enter expression: 3+4
Expr='3+4', val=7, add count thus far=1
Enter expression: [a=3+4:a+a]
Expr='[a=3+4:a+a]', val=14, add count thus far=3
Enter expression: ^Cexpr: interrupted
$
\end{TT}

This rudimentary calculator allows integer values, their addition and binding to identifiers.
Parsing is character based, no scanner is used to transform raw text into tokens.
No whitespace is allowed and a |let| expression is syntactically denoted by @[<nm>=<expr>:<expr>]@.

The example will allow us to discuss more AG features as well as typical use of AG.
We start with integer constants, addition followed by an attribute computation for the pretty printing:

\chunkCmdUse{Expr.1.data}

The root of the tree is now called |AGItf| to indicate (as a naming convention)
that this is the place where interfacing between the Haskell world
and the AG world takes place.

The definition demonstrates the use of the |SET| keyword which allows the naming of a group of nodes.
This name can later be used to declare attributes for all the named group of nodes at once.

The computation of a pretty printed representation follows the same pattern as the computation of |min| and |tree|
in the |repmin| example, because of its compositional and bottom-up nature.
The synthesized attribute |pp| is synthesized from the values of the |pp| attribute of the children of a node:

\chunkCmdUse{Expr.1.pp}

The pretty printing uses a pretty printing library with
combinators for values of type |PP_Doc| representing
pretty printed documents.
The library is not further discussed here; an overview of some of
the available combinators can be found in \figRef{pretty-printing-combinators}.

\begin{Figure}{Pretty printing combinators}{pretty-printing-combinators}
\begin{center}
\begin{tabular}{ll}
Combinator & Result
\\ \hline
|p1 >||< p2| & |p1| besides |p2|, |p2| at the right \\
|p1 `ppBesideSp` p2| & same as |>||<| but with an additional space in between \\
|p1 >-< p2| & |p1| above |p2| \\
|pp_parens p| & |p| inside parentheses \\
|text s| & string |s| as |PP_Doc| \\
|pp x| & pretty print |x| (assuming instance |PP x|) resulting in a |PP_Doc| \\
\end{tabular}
\end{center}
\end{Figure}

As a next step we add |let| expressions and use of identifiers in expressions.
This demonstrates an important feature of the AG system:
we may introduce new alternatives for a |<node>| as well as may introduce new attribute computations
in a separate piece of program text.
We first add new AST alternatives for |Expr|:

\chunkCmdUse{Expr.1.letdata}

One should keep in mind that the exensibility offered is simplistic of nature, but surprisingly flexible at the same time.
The idea is that node variants, attribute declarations and attribute rules for node variants can all occur textually separated.
The AG compiler gathers all definitions, combines, performs several checks (e.g. are attribute rules missing), and generates
the corresponding Haskell code.
All kinds of declarations can be distributed over several
text files to be included with a |INCLUDE| directive (not discussed any further).

Any addition of new node variants requires also the corresponding definitions
of already introduced attributes:

\chunkCmdUse{Expr.1.letpp}

The use of variables in the pocket calculator requires us to keep an administration of values bound to variables.
An association list is used to provide this environmental and scoped information:

\chunkCmdUse{Expr.1.env}

The scope is enforced by extending the inherited attribute |env| top-down in the AST.
Note that there is no need to specify a value for |@val.env| because
of the copy rules discussed later.
In the |Let| variant the inherited environment,
which is used for evaluating the right hand sided of the bound expression,
is extended with the new binding,
before being used as the inherited |env| attribute of the body.
The environment |env| is queried when the value of an expression is to be computed:

\chunkCmdUse{Expr.1.val}

The attribute |val| holds this computed value.
Because its value is needed in the `outside' Haskell world it is passed through |AGItf| (as part of |SET AllNT|)
as a synthesized attribute.
This is also the case for the previously introduced |pp| attribute as well as the following |count| attribute
used to keep track of the number of additions performed.
However, the |count| attribute is also passed as an inherited attribute.
Being both inherited and synthesized it is defined between the two vertical bars in the
|ATTR| declaration for |count|:

\chunkCmdUse{Expr.1.count}

The attribute |count| is said to be \IxAsDef{threaded} through the AST,
the AG solution to a global variable
or the use of state monad.
This is a result of the attribute being inherited as well as synthesized and
the copy rules.
Its effect is an automatic copying of the attribute in a preorder traversal of the AST.

\IxAsDef{Copy rule}s are attribute rules inserted by the AG system if a rule for an attribute |<attr>|
in a production of |<node>| is missing.
AG tries to insert a rule that copies the value of another attribute with the same name,
searching in the following order:

\begin{enumerate}
\item
Local attributes.
\item
The synthesized attribute of the children to the left of the child for which an inherited |<attr>| definition is missing,
with priority given to the nearest child fulfilling the condition.
A synthesized |<attr>| of a parent is considered to be at the right of any child's |<attr'>|.
\item
Inherited attributes (of the parent).
\end{enumerate}

In our example the effect is that for the |Let| variant of |Expr|

\begin{itemize}
\item
(inherited) |@lhs.count| is copied to (inherited) |@val.count|,
\item
(synthesized) |@val.count| is copied to (inherited) |@body.count|,
\item
(synthesized) |@body.count| is copied to (synthesized) |@lhs.count|.
\end{itemize}

Similar copy rules are inserted for the other variants.
Only for variant |Add| of |Expr| a different rule for |@lhs.count| is explicitly specified,
since here we have a non-trivial piece of semantics: i.e. we actually want to count something.

Automatic copy rule insertion can be both a blessing and curse.
A blessing because it takes away a lot of tedious work and minimises clutter
in the AG source text.
On the other hand it can be a curse,
because a programmer may have forgotten an otherwise required rule. If a copy rule can be inserted
the AG compiler will silently do so, and
the programmer will not be warned.

As with our previous example we can let a parser map input text to the invocations of semantic functions.
For completeness this source text has been included in \figRef{ag-primer-parser-expr}.
The result of parsing combined with the invocation of semantic functions will be a function taking inherited attributes
to a tuple holding all synthesized attributes.
Even though the order of the attributes in the result tuple is specified, its extraction via pattern matching
should be avoided.
The AG system can be instructed to create a wrapper function which knows how to extract the attributes out of the
result tuple:

\chunkCmdUse{Expr.1.wrapper}

The attribute values are stored in a data type with labeled fields for each attribute.
The attributes can be accessed with labels of the form |<attr>_Syn_<node>|.
The name of the wrapper is of the form |wrap_<node>|; the wrapper function is passed the result of the semantic function
and a data type holding inherited attributes:

\chunkCmdUse{Expr.1.main}

We face a similar problem with the passing of inherited attributes to the semantic function.
Hence inherited attributes are passed to the wrapper function via a data type with name |Inh_<node>| and a constructor with the same name,
with fields having labels of the form |<attr>_Inh_<node>|.
The |count| attribute is an example of an attribute which must be passed as an inherited attribute as well
as extracted as a synthesized attribute.

This concludes our introduction to the AG system.
Some topics have either not been mentioned at all or only shortly touched upon.
We provide a list of those topics together with a reference to the first use of the features which
are actually used later in \thispaper.
Each of these items is marked with |AGFeature| to indicate that it is about the AG system.

\begin{itemize}
\item
Type synonym, only for lists (see \secPageRef{ag-type-syn}).
\item
Left hand side patterns for simultaneous definition of rules (see \secPageRef{ag-lhs-pat}).
\item
Set notation for variant names in rules (see \secPageRef{ag-set-notation}).
\item
Local attributes (see \secPageRef{ag-loc-attr}).
\item
Additional copy rule via |USE| (see \secPageRef{ag-use-attr}).
\item
Additional copy rule via |SELF| (see \secPageRef{ag-self-attr}).
\item
Rule redefinition via |:=| (see \secPageRef{ag-redef-rule}).
%if False
\item
Typical use/pattern: decomposition.
\item
Typical use/pattern: gathering.
\item
Typical use/pattern: unique number generation.
%endif
\item
Cycle detection and other (experimental) features, commandline invocation, etc.
\end{itemize}

We will come back to the AG system itself in our conclusion.

\begin{Figure}{Parser for calculator example}{ag-primer-parser-expr}
\chunkCmdUse{Expr.1.parser}
\end{Figure}

%}