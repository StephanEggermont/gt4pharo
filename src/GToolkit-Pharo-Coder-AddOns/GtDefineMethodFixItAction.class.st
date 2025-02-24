Class {
	#name : #GtDefineMethodFixItAction,
	#superclass : #GtFixItAction,
	#instVars : [
		'classOrMetaClass'
	],
	#category : #'GToolkit-Pharo-Coder-AddOns-FixIt'
}

{ #category : #executing }
GtDefineMethodFixItAction >> addCoderAttributeinEditor: aBrTextEditor [
	| position |
	
	position := self attributePosition.
	(aBrTextEditor text from: position to: position)
		attributes:
			{((GtPharoMethodExpanderAttribute
				forClass: classOrMetaClass
				andSelector: node selector) isExpanded: true)}
]

{ #category : #accessing }
GtDefineMethodFixItAction >> attributePosition [
	^ node selectorParts last stopPosition
]

{ #category : #accessing }
GtDefineMethodFixItAction >> classOrMetaClass: anObject [
	classOrMetaClass := anObject
]

{ #category : #private }
GtDefineMethodFixItAction >> compileMethod [
	| refactoring |
	refactoring := RBAddMethodRefactoring
		addMethod: self methodSource
		toClass: classOrMetaClass
		inProtocols: {(sourceCoder protocol ifNil: [ #accessing ])}.
	refactoring execute
]

{ #category : #accessing }
GtDefineMethodFixItAction >> description [
	^ 'Create method ' , node selector , ' in class ', classOrMetaClass name
]

{ #category : #executing }
GtDefineMethodFixItAction >> executeOn: anEditorElement [
	self compileMethod.
	self clearFixItAttributeInEditor: anEditorElement editor.
	self addCoderAttributeinEditor: anEditorElement editor.
]

{ #category : #accessing }
GtDefineMethodFixItAction >> id [
	<return: #BlElementId>

	^ GtDefineMethodFixItActionElementId
]

{ #category : #private }
GtDefineMethodFixItAction >> methodSource [
	node arguments isEmpty
		ifTrue: [ ^ node selector ].
	^ String
		streamContents: [ :stream | 
			| variables baseName name index |
			variables := Set new.
			node selectorParts
				with: node arguments
				do: [ :eachSelectorPart :arg | 
					stream
						nextPutAll: eachSelectorPart selector;
						space.
					baseName := arg isVariable
						ifTrue: [ arg variableName ]
						ifFalse: [ 
							arg isLiteral
								ifTrue: [ arg literalValue class canonicalArgumentName ]
								ifFalse: [ 'anObject' ] ].
					index := 0.
					name := baseName.
					[ variables includes: name ]
						whileTrue: [ index := index + 1.
							name := baseName , index printString ].
					variables add: name.
					stream
						nextPutAll: name;
						space ] ]
]
