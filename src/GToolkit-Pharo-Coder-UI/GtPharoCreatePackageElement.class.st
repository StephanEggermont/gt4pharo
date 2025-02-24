Class {
	#name : #GtPharoCreatePackageElement,
	#superclass : #GtCreateElement,
	#instVars : [
		'packageBlock'
	],
	#category : #'GToolkit-Pharo-Coder-UI-Behavior'
}

{ #category : #initialization }
GtPharoCreatePackageElement >> buildDefinitionEditor [
	| theProperties saveButton |
		
	theProperties := BlElement new
		layout: (BlGridLayout new columnCount: 2);
		constraintsDo: [ :c |
			c horizontal matchParent.
			c vertical fitContent ];
		padding: (BlInsets all: 10).
		
	theProperties addShortcut: (BlShortcutWithAction new
		combination: BlKeyCombination arrowUp;
		action: [ :anEvent |
			anEvent currentTarget deepestFocusedChild ifNotNil: [ :aFocusedChild |
				BlFocusFinder new
					up;
					root: anEvent currentTarget;
					referenceElement: aFocusedChild;
					nextFocusDo: [ :aNextFocusElement | aNextFocusElement requestFocus ] ] ]).

	theProperties addShortcut: (BlShortcutWithAction new
		combination: BlKeyCombination arrowDown;
		action: [ :anEvent |
			anEvent currentTarget deepestFocusedChild ifNotNil: [ :aFocusedChild |
				BlFocusFinder new
					down;
					root: anEvent currentTarget;
					referenceElement: aFocusedChild;
					nextFocusDo: [ :aNextFocusElement | aNextFocusElement requestFocus ] ] ]).

	saveButton := BrButton new
		icon: BrGlamorousVectorIcons accept;
		beSmallSize;
		aptitude: BrGlamorousButtonWithIconAptitude new;
		label: 'Save';
		action: [ self createPackage ];
		constraintsDo: [ :c | c grid horizontal span: 2 ];
		disable.

	definition package
		when: GtBehaviorChangeEvent
		do: [ :event | saveButton enabled: definition isValidForCreation ].
	
	theProperties addChild: (self buildPackageLabel constraintsDo: [ :c | c grid horizontal span: 2 ]).

	definition tag editors do: [ :eachEditor |
		eachEditor definition
			when: GtBehaviorChangeEvent
			do: [ :event | saveButton enabled: definition isValidForCreation ].
		theProperties addChildren: { 
				(self buildSectionLabel: eachEditor title).
				(eachEditor
					aptitude: [ self editableLabelLook ];
					margin: self buttonMargin;
					asElement) } ].

	theProperties addChild: saveButton.

	^ theProperties
]

{ #category : #'private - ui' }
GtPharoCreatePackageElement >> buildPackageLabel [
	^ definition package packageEditor asElement
		aptitude:
			(BrGlamorousEditableLabelAptitude new
				defaultBackground: Color transparent;
				glamorousCodeFont;
				bold;
				fontSize: 18);
		yourself
]

{ #category : #initialization }
GtPharoCreatePackageElement >> createPackage [
	| change |
	change := definition createPackageChange.
	GtPharoCodeModifier current performRefactoryChange: change.
	packageBlock notNil
		ifTrue: [ packageBlock cull: change package cull: change tag ]
]

{ #category : #initialization }
GtPharoCreatePackageElement >> forPackage: aPackage [
	definition package name: aPackage name
]

{ #category : #initialization }
GtPharoCreatePackageElement >> initialize [
	super initialize.
	definition := GtCategoryDefinition empty.
	definition package name: 'NewPackage'.
	self addChild: self buildDefinitionEditor
]

{ #category : #accessing }
GtPharoCreatePackageElement >> packageBlock: aBlock [
	packageBlock := aBlock
]
