Class {
	#name : #GtPharoSnippetCoderViewModel,
	#superclass : #GtPharoSourceCoderViewModel,
	#instVars : [
		'context'
	],
	#category : #'GToolkit-Pharo-Coder-UI-! View Models'
}

{ #category : #accessing }
GtPharoSnippetCoderViewModel >> allowSaveDueTo: anObject [
	"do nothing"
]

{ #category : #'api - coder model' }
GtPharoSnippetCoderViewModel >> behavior [
	^ self selfObject class
]

{ #category : #accessing }
GtPharoSnippetCoderViewModel >> context [
	^ context
]

{ #category : #accessing }
GtPharoSnippetCoderViewModel >> context: anObject [
	context := anObject
]

{ #category : #initialization }
GtPharoSnippetCoderViewModel >> defaultBindingStrategy [
	| defaultBindings |
	
	defaultBindings := GtLocalSnippetBindings new.
	defaultBindings sharedBindings: GtSnippetBindings new.

	^ GtSnippetBindingStrategy new bindings: defaultBindings
]

{ #category : #'private - evaluation' }
GtPharoSnippetCoderViewModel >> evaluationContext [
	^ super evaluationContext
		runtimeContext: self context
]

{ #category : #'api - coder model' }
GtPharoSnippetCoderViewModel >> hasDeclaredVariableNamed: aVariableName [
	"Return true if a variable with a given name is declared"
	<return: #Boolean>

	(super hasDeclaredVariableNamed: aVariableName)
		ifTrue: [ ^ true ].

	"in case of the workspace we ignore non-capitalized variables as they are temporary variables
	and are always declared"
	aVariableName first isUppercase not
		ifTrue: [ ^ true ].

	^ false
]

{ #category : #'api - coder model' }
GtPharoSnippetCoderViewModel >> onCoderModelChanged [
	super onCoderModelChanged.

	self bindingStrategy bindings
		localAt: #thisCoderViewModel
		put: self.
		
	self bindingStrategy bindings
		localAt: #thisCoder
		put: self coderModel
]

{ #category : #accessing }
GtPharoSnippetCoderViewModel >> preventSaveDueTo: anObject [
	"do nothing"
]

{ #category : #'api - bindings' }
GtPharoSnippetCoderViewModel >> sharedBindings [
	^ self bindingStrategy bindings sharedBindings
]

{ #category : #'api - bindings' }
GtPharoSnippetCoderViewModel >> sharedBindings: aGtSnippetBindings [
	self bindingStrategy bindings sharedBindings: aGtSnippetBindings
]
