"
# Source coder
I am a coder for the source code. I know about the `sourceCode` ({{gtClass:GtCoderSourceCode}}) and `completionStrategy` ({{gtClass:GtCompletionStrategy}}).
## Actions
All source coders know about basic actions such as code evaluation (`do it all, do it and go, do it selection and go`) or different browsing abilities. Those actions can only be executed in a presence of a text editor UI element that is passed as an argument. It is required to provide a text editor element in order to get information about cursor position or current selection, in addition to being able to have a UI context to notify user or provide her with a feedback of the executed action. All actions are always performed on the current source code text (expanded/collapsed state is not taken into account).
## Add-ons
The source coder extends the addons ({{gtClass:GtCoderAddOns}}) with extra stylers (see {{gtClass:GtSourceCoderAddOns}}) that allows users to add extra contextual information within the text editor via text attributes.
## Implementation details
It is important to notice that I do not directly reference a text editor and I should not store any UI related information such as cursor position or selection.


"
Class {
	#name : #GtPharoSourceCoder,
	#superclass : #GtSourceCoder,
	#category : #'GToolkit-Pharo-Coder-Coders'
}

{ #category : #'private - actions' }
GtPharoSourceCoder class >> debug: aCompiledMethod receiver: anObject in: evalContext [
	| guineaPig suspendedContext debugSession |

	guineaPig := [ aCompiledMethod
		valueWithReceiver: anObject
		arguments: (evalContext ifNil: [ #() ] ifNotNil: [ {evalContext} ]) ]
		newProcess.
	suspendedContext := guineaPig suspendedContext.
	
	debugSession := guineaPig newDebugSessionNamed: 'debug it' startedAt: suspendedContext.
	debugSession stepIntoUntil: [:currentContext | 
		currentContext method == aCompiledMethod ].
	
	Smalltalk tools debugger
		openOn: debugSession
		withFullView: true
]

{ #category : #constants }
GtPharoSourceCoder class >> sourceEditorName [
	^ #editor
]

{ #category : #'private - refactorings' }
GtPharoSourceCoder >> addRefactoringChangesPreview: aRefactoring at: position [
	self
		addRefactoringChangesPreview: aRefactoring
		at: position
		whenComplete: nil
]

{ #category : #'api - accessing' }
GtPharoSourceCoder >> behavior [
	"Return an optional Behavior in context of which this coder operates.
	Behavior (class, metaclass or trait) helps various add-ons and styler to provide users with better
	contextual information"
	<return: #Behavior>
	
	^ UndefinedObject
]

{ #category : #'api - actions examples' }
GtPharoSourceCoder >> canExecuteExample [
	<return: #Boolean>

	^ false
]

{ #category : #private }
GtPharoSourceCoder >> classOrMetaClass [
	self
		deprecated: 'Use #behavior instead.'
		transformWith: '`@receiver classOrMetaClass' -> '`@receiver behavior'.
		
	^ self behavior
]

{ #category : #'private - ast' }
GtPharoSourceCoder >> detectBehaviorAt: aTextPosition ifFound: aFoundBlock ifNone: aNoneBlock [
	"Try to find a Behavior at the given source text position and evaluate a found block
	with the found Behavior as an argument if such Beahvior was found or none block otherwise. Return the result"
	<return: #Object>

	^ self
		variableNodeAt: aTextPosition
		ifFound: [ :aVariableNode |
			self
				variableNodeToBehavior: aVariableNode
				ifFound: aFoundBlock
				ifNone: aNoneBlock ]
		ifNone: aNoneBlock
]

{ #category : #'private - ast' }
GtPharoSourceCoder >> detectBehaviorIn: aSourceString ifFound: aFoundBlock ifNone: aNoneBlock [
	"Try to find a Behavior within the given source string and evaluate a found block
	with the found Behavior as an argument if such Beahvior was found or none block otherwise. Return the result"
	<return: #Object>
	^ self
		variableNodeIn: aSourceString
		ifFound: [ :aVariableNode |
			self
				variableNodeToBehavior: aVariableNode
				ifFound: aFoundBlock
				ifNone: aNoneBlock ]
		ifNone: aNoneBlock
]

{ #category : #'private - ast' }
GtPharoSourceCoder >> detectReferencesFilterAt: aTextPosition ifFound: aFoundBlock ifNone: aNoneBlock [
	"Try to find a name (symbol) in the source code at a given text position of the entity that plays a role
	of the entity reference in the system and create a corresponding references filter.
	Evaluate a found block with the found reference as an argument or none block otherwise. Return the result"
	<return: #Object>
	^ self
		nodeAt: aTextPosition
		ifFound: [ :aNode |
			self
				nodeToReferencesFilter: aNode
				ifFound: aFoundBlock
				ifNone: aNoneBlock ]
		ifNone: aNoneBlock
]

{ #category : #'private - ast' }
GtPharoSourceCoder >> detectReferencesFilterIn: aSourceString ifFound: aFoundBlock ifNone: aNoneBlock [
	"Try to find a name (symbol) in the given source string of the entity that plays a role
	of the entity reference in the system and create a corresponding references filter.
	Evaluate a found block with the found reference as an argument or none block otherwise. Return the result"
	<return: #Object>
	| aNode |

	aNode := GtPharoParser
		parseWithErrors: aSourceString
		startingAt: GtPharoParser startingStateForStatement.

	^ self
		nodeToReferencesFilter: aNode
		ifFound: aFoundBlock
		ifNone: aNoneBlock
]

{ #category : #'private - ast' }
GtPharoSourceCoder >> detectSelectorAt: aTextPosition ifFound: aFoundBlock ifNone: aNoneBlock [
	"Try to find a message selector at the given source text position and evaluate a found block
	with the found selector as an argument if such selector was found or none block otherwise. Return the result"
	<return: #Object>

	^ self
		nodeAt: aTextPosition
		ifFound: [ :aNode |
			self
				nodeToSelector: aNode
				ifFound: aFoundBlock
				ifNone: aNoneBlock ]
		ifNone: aNoneBlock
]

{ #category : #'private - ast' }
GtPharoSourceCoder >> detectSelectorIn: aSourceString ifFound: aFoundBlock ifNone: aNoneBlock [
	"Try to find a message selector in the given source string and evaluate a found block
	with the found selector as an argument if such selector was found or none block otherwise. Return the result"
	<return: #Object>
	| aNode |

	aNode := GtPharoParser 
		parseWithErrors: aSourceString
		startingAt: GtPharoParser startingStateForStatement.

	^ self
		nodeToSelector: aNode
		ifFound: aFoundBlock
		ifNone: aNoneBlock
]

{ #category : #'private - actions' }
GtPharoSourceCoder >> evaluationContext [
	<return: #GtSourceCoderEvaluationContext>

	^ GtPharoSourceCoderEvaluationContext new
		requesterObject: self;
		coder: self
]

{ #category : #'private - ast' }
GtPharoSourceCoder >> extractableNodesAt: anIndex [
	"Return a collection of extractable nodes that intersect a given interval"
	<return: #Collection of: #GtPharoProgramNode>

	^ self
		nodeAt: anIndex
		ifFound: [ :aNode |
			aNode isSequence
				ifTrue: [ aNode statements select: [ :eachNode | eachNode intersectsInterval: (anIndex to: anIndex) ] ]
				ifFalse: [ { aNode } ] ]
		ifNone: [ #() ]
]

{ #category : #'private - ast' }
GtPharoSourceCoder >> extractableNodesWithin: anInterval [
	"Return a collection of extractable nodes that intersect a given interval"
	<return: #Collection of: #GtPharoProgramNode>

	^ self
		nodeWithin: anInterval
		ifFound: [ :aNode |
			aNode isSequence
				ifTrue: [ aNode statements select: [ :eachNode | eachNode intersectsInterval: anInterval ] ]
				ifFalse: [ { aNode } ] ]
		ifNone: [ #() ]
]

{ #category : #testing }
GtPharoSourceCoder >> hasObjectAttribute [
	<return: #Boolean>

	^ false
]

{ #category : #testing }
GtPharoSourceCoder >> isForMethod [
	^ false
]

{ #category : #private }
GtPharoSourceCoder >> newCompletionStrategy [
	^ GtPharoCompletionStrategy new
		classOrMetaClass: self behavior;
		yourself
]

{ #category : #'private - ast rb' }
GtPharoSourceCoder >> newRbAST: aString [
	| ast |
	ast := self parseExpression: aString requestor: nil.
	ast doSemanticAnalysis.
	^ ast
]

{ #category : #'private - ast' }
GtPharoSourceCoder >> nodeAt: aTextPosition ifFound: aFoundBlock ifNone: aNoneBlock [
	<return: #Object>
	[
		| theAST innerNode |
		theAST := self astAwait.
		theAST
			withAllNodesDo: [ :node | 
				(aTextPosition between: node startPosition and: node stopPosition)
					ifTrue: [ innerNode := node ] ].
		
		((innerNode isName or: [ innerNode isKeyword ])
			and: [ innerNode parent notNil ])
				ifTrue: [ innerNode := innerNode parent ].
		
		^ innerNode ifNil: aNoneBlock ifNotNil: aFoundBlock ]
			on: Error
			do: [ :ex | ex return ].

	^ aNoneBlock value
]

{ #category : #'private - ast' }
GtPharoSourceCoder >> nodeToReferencesFilter: aNode ifFound: aFoundBlock ifNone: aNoneBlock [
	"Try to create a references filter from a given AST node. If aNode is not suitable
	for creating a filter, also check all parents of that node. Evaluate aFoundBlock if a references filter
	was built and aNoneBlock otherwise, return the result of the block evaluation"
	<return: #Object>
	| aCurrentNode |

	aCurrentNode := aNode.

	[ aCurrentNode notNil ] whileTrue: [
		(aCurrentNode isKindOf: GtPharoVariableNode)
			ifTrue: [
				^ self
					variableNodeToReferencesFilter: aCurrentNode
					ifFound: aFoundBlock
					ifNone: aNoneBlock ].
		(aCurrentNode isKindOf: GtPharoSymbolLiteralNode)
			ifTrue: [ ^ aFoundBlock value: (self referencesFilterForLiteral: aCurrentNode asSymbol) ].
		(aCurrentNode isKindOf: GtPharoStringLiteralNode)
			ifTrue: [ ^ aFoundBlock value: (self referencesFilterForString: aCurrentNode value value) ].
		(aCurrentNode isKindOf: GtPharoCharacterLiteralNode)
			ifTrue: [ ^ aFoundBlock value: (self referencesFilterForCharacter: aCurrentNode value value) ].
		(aCurrentNode isKindOf: GtPharoBooleanLiteralNode)
			ifTrue: [ ^ aFoundBlock value: (self referencesFilterForBoolean: aCurrentNode value value) ].
		(aCurrentNode isKindOf: GtPharoNumberLiteralNode)
			ifTrue: [ ^ aFoundBlock value: (self referencesFilterForNumber: aCurrentNode value value) ].
		((aCurrentNode isKindOf: GtPharoMessageNode)
			or: [ aCurrentNode isKindOf: GtPharoMethodPatternNode ])
			ifTrue: [ ^ aFoundBlock value: (self referencesFilterForLiteral: aCurrentNode selector) ].
		(aCurrentNode isKindOf: GtPharoMessageSendNode)
			ifTrue: [ aCurrentNode := aCurrentNode message ]
			ifFalse: [ aCurrentNode := aCurrentNode parent ] ].

	^ aNoneBlock value
]

{ #category : #'private - ast' }
GtPharoSourceCoder >> nodeToSelector: aNode ifFound: aFoundBlock ifNone: aNoneBlock [
	"Try to extract a message selector from a given AST node. If aNode is not suitable
	for extracting a selector, also check all parents of that node. Evaluate aFoundBlock if a selector
	is found and aNoneBlock otherwise, return the result of the block evaluation"
	<return: #Object>
	| aCurrentNode |

	aCurrentNode := aNode.
	[ aCurrentNode notNil ]
		whileTrue: [
			(aCurrentNode isKindOf: GtPharoVariableNode)
				ifTrue: [ ^ aFoundBlock value: aCurrentNode name source asSymbol ].
			(aCurrentNode isKindOf: GtPharoSymbolLiteralNode)
				ifTrue: [ ^ aFoundBlock value: aNode asSymbol ].
			(aCurrentNode isKindOf: GtPharoMessageSendNode)
				ifTrue: [ aCurrentNode := aCurrentNode message ].
			((aCurrentNode isKindOf: GtPharoMessageNode)
				or: [ aCurrentNode isKindOf: GtPharoMethodPatternNode ])
				ifTrue: [ ^ aFoundBlock value: aCurrentNode selector ].
			aCurrentNode := aCurrentNode parent ].
	^ aNoneBlock value
]

{ #category : #'private - ast' }
GtPharoSourceCoder >> nodeWithin: anInterval ifFound: aFoundBlock ifNone: aNoneBlock [
	<return: #Object>

	[
		| theAST |
		theAST := self astAwait.
		^ theAST
			bestNodeFor: anInterval
			ifFound: aFoundBlock
			ifNone: aNoneBlock ]
				on: Error
				do: [ :ex | ex return ].

	^ aNoneBlock value
]

{ #category : #'private - notifying' }
GtPharoSourceCoder >> notifyParseError: aString at: anInteger [
	self announce: (GtCoderParseError new
		coder: self;
		errorMessage: aString;
		location: anInteger)
]

{ #category : #'private - notifying' }
GtPharoSourceCoder >> notifyToolSpawn: aTool withDestination: aSpawnDestination [
	self announce: (GtCoderToolSpawnRequest new 
		tool: aTool;
		spawnDestination: aSpawnDestination;
		coder: self)
]

{ #category : #'api - accessing' }
GtPharoSourceCoder >> object [
	"Deprecated! Use GtPharoSourceCoderViewModel>>#selfObject: instead"
	<return: #Object or: nil>

	self deprecated: 'Use GtPharoSourceCoderViewModel>>#selfObject instead'.

	^ nil
]

{ #category : #'api - accessing' }
GtPharoSourceCoder >> object: anObject [
	"Set an object in the context of which the source code should be modified (may influence self binding)"

	self deprecated: 'Use GtPharoSourceCoderViewModel>>#selfObject: instead'.
]

{ #category : #accessing }
GtPharoSourceCoder >> package [
	^ self attributeNamed: #package
]

{ #category : #accessing }
GtPharoSourceCoder >> packageTag [
	^ self attributeNamed: #packageTag
]

{ #category : #'private - ast rb' }
GtPharoSourceCoder >> parse: aString asExpression: isExpression requestor: aRequestor [
	^ (self behavior ifNil: [ UndefinedObject ]) compiler
		source: aString;
		noPattern: isExpression;
		options: #(+ optionParseErrors + optionSkipSemanticWarnings);
		requestor: aRequestor;
		parse
]

{ #category : #'private - ast rb' }
GtPharoSourceCoder >> parseExpression: aString requestor: aRequestor [
	^ self parse: aString asExpression: true requestor: aRequestor
]

{ #category : #'private - ast rb' }
GtPharoSourceCoder >> parseMethod: aString [
	^ self parse: aString asExpression: false requestor: nil
]

{ #category : #'private - actions' }
GtPharoSourceCoder >> primitiveAnonymousCompile: aSourceString inContext: aGtPharoSourceCoderEvaluationContext onFailDo: anEvaluationFailBlock [
	<return: #CompiledMethod>
	| isForMethod methodClass |

	isForMethod := self isForMethod and: [
		aGtPharoSourceCoderEvaluationContext evaluatedInterval = (1 to: aGtPharoSourceCoderEvaluationContext sourceString size) ].
	
	isForMethod
		ifFalse: [ aGtPharoSourceCoderEvaluationContext withSnippetBindingStrategy ].

	methodClass := aGtPharoSourceCoderEvaluationContext runtimeContext
		ifNil: [ aGtPharoSourceCoderEvaluationContext receiverObject class ]
		ifNotNil: [ :aContext | aContext methodClass ].

	^ GtPharoCodeModifier current critical: [
		self class compiler
			source: aSourceString;
			class: methodClass newAnonymousSubclass;
			context: aGtPharoSourceCoderEvaluationContext runtimeContext;
			requestor: aGtPharoSourceCoderEvaluationContext;
			noPattern: isForMethod not;
			failBlock: anEvaluationFailBlock;
			compile ]
]

{ #category : #'private - actions' }
GtPharoSourceCoder >> primitiveDebug: aSourceString inContext: aGtPharoSourceCoderEvaluationContext onFailDo: anEvaluationFailBlock [
	| aCompiledMethodToDebug |

	aCompiledMethodToDebug := self
		primitiveAnonymousCompile: aSourceString
		inContext: aGtPharoSourceCoderEvaluationContext
		onFailDo: [ ^ anEvaluationFailBlock value ].

	self class
		debug: aCompiledMethodToDebug
		receiver: aGtPharoSourceCoderEvaluationContext receiverObject
		in: aGtPharoSourceCoderEvaluationContext runtimeContext
]

{ #category : #'private - actions' }
GtPharoSourceCoder >> primitiveEvaluate: aSourceString inContext: aGtPharoSourceCoderEvaluationContext onFailDo: anEvaluationFailBlock [
	| aCompiledMethodToEvaluate |

	aCompiledMethodToEvaluate := self
		primitiveAnonymousCompile: aSourceString
		inContext: aGtPharoSourceCoderEvaluationContext
		onFailDo: [ ^ anEvaluationFailBlock value ].

	^ aGtPharoSourceCoderEvaluationContext receiverObject
		withArgs: (aGtPharoSourceCoderEvaluationContext runtimeContext
			ifNil: [ #() ]
			ifNotNil: [ { aGtPharoSourceCoderEvaluationContext runtimeContext } ])
		executeMethod: aCompiledMethodToEvaluate
]

{ #category : #accessing }
GtPharoSourceCoder >> protocol [
	^ #accessing
]

{ #category : #'private - ast rb' }
GtPharoSourceCoder >> rbAST [
	| source |

	"The AST should be built out of the `characters` of the source text.
	This is needed to support `crlf` and logical items
	see https://github.com/feenkcom/gtoolkit/issues/593"
	source := self currentSourceString.
	^ [ self newRbAST: source ]
		on: Error
		do: [ :ex | ex return: nil ]
]

{ #category : #'private - ast' }
GtPharoSourceCoder >> referencesFilterForBoolean: aBooleanAsString [
	"aBooleanAsString would be a string 'true', which should be evaluated to get a boolean"

	^ self referencesFilterForLiteral: (Object evaluate: aBooleanAsString)
]

{ #category : #'private - ast' }
GtPharoSourceCoder >> referencesFilterForCharacter: aCharacterAsString [
	"aCharacterAsString would be a string '$a', which should be evaluated to get a character"

	^ self referencesFilterForLiteral: (Object evaluate: aCharacterAsString)
]

{ #category : #'private - ast' }
GtPharoSourceCoder >> referencesFilterForLiteral: anObject [
	^ GtSearchReferencesFilter literal: anObject
]

{ #category : #'private - ast' }
GtPharoSourceCoder >> referencesFilterForNumber: aNumberAsString [
	"aNumberAsString would be a string '42', which should be evaluated to get a boolean"

	^ self referencesFilterForLiteral: (Object evaluate: aNumberAsString)
]

{ #category : #'private - ast' }
GtPharoSourceCoder >> referencesFilterForString: aString [
	"we have to dispatch through the compiler and to evaluate: the string, otherwise it will not be searched for
	because it is compared by identity and compiler does some string optimizations"

	^ self referencesFilterForLiteral: (Object evaluate: aString)
]

{ #category : #'private - ast' }
GtPharoSourceCoder >> referencesFilterForSymbol: aSymbol [
	^ self referencesFilterForLiteral: aSymbol
]

{ #category : #'api - accessing' }
GtPharoSourceCoder >> source [
	<return: #String>

	self
		deprecated: 'Use #currentSourceString instead'
		transformWith: '`@receiver source' -> '`@receiver currentSourceString'.
		
	^ self currentSourceString
]

{ #category : #private }
GtPharoSourceCoder >> validateSyntax [
	<return: #Boolean>

	[ self computeAst ]
		on: SmaCCParserError
		do: [ :ex | 
			self notifyParseError: ex messageText at: ex tag position.
			^ false ].
	^ true
]

{ #category : #'private - ast' }
GtPharoSourceCoder >> variableNodeAt: aTextPosition ifFound: aFoundBlock ifNone: aNoneBlock [
	"Try to find a variable node ${class:GtPharoVariableNode}$ at a given text position and evaluate a found
	block if such node exists and none block otherwise. Return the result"
	<return: #Object>
	[
		| theAST |
		theAST := self astAwait.
		theAST
			withAllNodesOfType: GtPharoVariableNode
			do: [ :node | 
				(aTextPosition between: node startPosition and: node stopPosition)
					ifTrue: [ ^ aFoundBlock value: node ] ] ]
		on: Error
		do: [ :ex | ex return ].

	^ aNoneBlock value
]

{ #category : #'private - ast' }
GtPharoSourceCoder >> variableNodeIn: aSourceString ifFound: aFoundBlock ifNone: aNoneBlock [
	"Try to extract a variable node ${class:GtPharoVariableNode}$ in a given string and evaluate a found block
	if such node was found and a none block otherwise. Return the result."
	<return: #Object>
	| eachNode |

	eachNode := GtPharoParser 
		parseWithErrors: aSourceString
		startingAt: GtPharoParser startingStateForStatement.

	[ eachNode isNil ]
		whileFalse: [ 
			(eachNode isKindOf: GtPharoVariableNode)
				ifTrue: [ ^ aFoundBlock value: eachNode ].
			eachNode := eachNode parent ].

	^ aNoneBlock value
]

{ #category : #'private - ast' }
GtPharoSourceCoder >> variableNodeToBehavior: aVariableNode ifFound: aFoundBlock ifNone: aNoneBlock [
	"Convert a given variable node to a behavior registered in the system and evaluate
	a found block if such behavior exists, evaluate none block otherwise. Return the result"
	<return: #Object>
	| aVariableName aBehavior |

	aVariableName := aVariableNode name value asSymbol.

	aBehavior := self class environment
		at: aVariableName
		ifAbsent: [ ^ aNoneBlock value ].

	aBehavior isBehavior
		ifFalse: [ ^ aNoneBlock value ].

	^ aFoundBlock value: aBehavior
]

{ #category : #'private - ast' }
GtPharoSourceCoder >> variableNodeToReferencesFilter: aVariableNode ifFound: aFoundBlock ifNone: aNoneBlock [
	"Convert a given variable node to the references filter and evaluate
	a found block if such filter can be created, evaluate none block otherwise. Return the result"
	<return: #Object>
	| aVariableName aVariableIndex aDefiningClass aBinding |
	
	aVariableName := aVariableNode name source.
	aVariableIndex := self behavior instVarIndexFor: aVariableName.
	aVariableIndex > 0
		ifTrue: [
			aDefiningClass := self behavior whichClassDefinesInstVar: aVariableName.
			^ aFoundBlock value: (GtSearchInstanceVariableReferenceFilter
				forClassAndSubclasses: aDefiningClass
				andVariable: aVariableName) ].

	aBinding := self behavior bindingOf: aVariableName.
	aBinding notNil
		ifTrue: [ ^ aFoundBlock value: (GtSearchReferencesFilter literal: aBinding) ].
		
	"At this point we know that it is not an instance/class varaible, nor it is a binding.
	We therefore fallback to the basic literal references filter"

	^ aFoundBlock value: (self referencesFilterForLiteral: aVariableName asSymbol)
]

{ #category : #accessing }
GtPharoSourceCoder >> zincAddOnFor: anAST into: coderAddOns [
	<gtAstCoderAddOns: 100>
	coderAddOns addStyler: GtPharoZincStyler new
]
