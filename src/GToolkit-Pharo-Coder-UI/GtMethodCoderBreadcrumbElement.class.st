"
# Source coder breadcrumb
{{gtExample:GtMethodCoderBreadcrumbElementExamples>>#breadcrumbForSourceCoder}}

"
Class {
	#name : #GtMethodCoderBreadcrumbElement,
	#superclass : #BrBreadcrumb,
	#instVars : [
		'sourceCoderUIModel'
	],
	#category : #'GToolkit-Pharo-Coder-UI-! Views'
}

{ #category : #accessing }
GtMethodCoderBreadcrumbElement >> coder: aCoder [
	self 
		deprecated: 'Use #sourceCoderUIModel: instead.'
		transformWith: '`@receiver coder: `@arg' -> '`@receiver sourceCoderUIModel: `@arg'.
		
	self sourceCoderUIModel: aCoder
]

{ #category : #initialization }
GtMethodCoderBreadcrumbElement >> initialize [
	super initialize.
	self
		aptitude:
			(BrGlamorousBreadcrumbAptitude new
				separator: [ BrLabel new
						aptitude:
							(BrGlamorousLabelAptitude new thin
								foreground: self theme button defaultTextColor);
						text: '>';
						margin: (BlInsets left: 5 right: 5) ]).
	self fitContent
]

{ #category : #'instance creation' }
GtMethodCoderBreadcrumbElement >> newBreadcrumbItemElementsFor: aSourceCoder [
	<return: #Collection of: #BrButton>

	^ aSourceCoder breadcrumbActions
		collect: [ :eachBreadcrumbAction | self newBreadcrumbItemFor: eachBreadcrumbAction ]
]

{ #category : #'instance creation' }
GtMethodCoderBreadcrumbElement >> newBreadcrumbItemFor: aGtSourceCoderBreadcrumbAction [
	^ BrButton new
		aptitude: (BrGlamorousLabelAptitude new
			foreground: aGtSourceCoderBreadcrumbAction foreground;
			fontSize: 12);
		label: aGtSourceCoderBreadcrumbAction name;
		model: aGtSourceCoderBreadcrumbAction;
		action: [ :aButtonElement :aButtonModel | aButtonModel model performSourceCoderActionFrom: aButtonElement ]
]

{ #category : #'event handling' }
GtMethodCoderBreadcrumbElement >> onCoderClassChanged: anAnnouncement [
	| aCoder |
	
	aCoder := anAnnouncement coder.
	self enqueueTask: (BlTaskAction new action: [ self updateBreadcrumbElements: aCoder ])
]

{ #category : #'event handling' }
GtMethodCoderBreadcrumbElement >> onCoderMethodModified: anAnnouncement [
	anAnnouncement coder isModified
		ifTrue: [ self background: self theme status errorBackgroundColor ]
		ifFalse: [ self background: Color white ]
]

{ #category : #'event handling' }
GtMethodCoderBreadcrumbElement >> onCoderSourceTextModified: anAnnouncement [
	anAnnouncement coder isModified
		ifTrue: [ self background: self theme status failureBackgroundColor ]
		ifFalse: [ self background: Color white ]
]

{ #category : #accessing }
GtMethodCoderBreadcrumbElement >> sourceCoderUIModel: aGtSourceCoderUIModel [
	sourceCoderUIModel ifNotNil: [ :aPreviousCoderUIModel | 
		aPreviousCoderUIModel coder announcer unsubscribe: self ].
	
	sourceCoderUIModel := aGtSourceCoderUIModel.
	self updateBreadcrumbElements: sourceCoderUIModel coder.
	
	sourceCoderUIModel coder weak
		when: GtCoderClassAdded, GtCoderClassRenamed, GtCoderClassRemoved
		send: #onCoderClassChanged:
		to: self.

	sourceCoderUIModel coder weak
		when: GtCoderMethodModified
		send: #onCoderMethodModified:
		to: self.
		
	sourceCoderUIModel coder weak
		when: GtCoderSourceCodeChanged
		send: #onCoderSourceTextModified:
		to: self.
		
	
]

{ #category : #accessing }
GtMethodCoderBreadcrumbElement >> updateBreadcrumbElements: aMethodCoder [
	self removeAllItems.
	self addItems: (self newBreadcrumbItemElementsFor: aMethodCoder).
	aMethodCoder isModified
		ifTrue: [ self background: self theme status failureBackgroundColor ]
		ifFalse: [ self background: Color white ]
]
