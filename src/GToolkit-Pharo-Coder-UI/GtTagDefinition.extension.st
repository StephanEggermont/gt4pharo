Extension { #name : #GtTagDefinition }

{ #category : #'*GToolkit-Pharo-Coder-UI' }
GtTagDefinition >> browseFrom: anEvent [
	| aRealPackage |

	aRealPackage := RPackageOrganizer default
		packageNamed: self parent category package name
		ifAbsent: [ ^ self ].

	aRealPackage
		classTagNamed: self name
		ifPresent: [ :aTag |
			| aPackageTagCoder aCoderEvent |
			aPackageTagCoder := (GtPharoPackageTagCoder forPackageTag: aTag)
				packageCoder: (GtPharoPackageCoder forPackage: aRealPackage).
			aCoderEvent := GtCoderToSpawn new coder: aPackageTagCoder.
			anEvent currentTarget fireEvent: aCoderEvent.
			aCoderEvent isConsumed
				ifFalse: [ anEvent currentTarget phlow spawnTool: (GtReadyCoderTool coder: aCoderEvent coder) ] ]
]

{ #category : #'*GToolkit-Pharo-Coder-UI' }
GtTagDefinition >> editors [
	^ { self tagEditor }
]

{ #category : #'*GToolkit-Pharo-Coder-UI' }
GtTagDefinition >> readers [
	^ { self tagReader }
]

{ #category : #'*GToolkit-Pharo-Coder-UI' }
GtTagDefinition >> replaceFrom: anEvent [
	| aRealPackage |

	aRealPackage := RPackageOrganizer default
		packageNamed: self parent category package name
		ifAbsent: [ ^ self ].

	aRealPackage
		classTagNamed: self name
		ifPresent: [ :aTag |
			| aPackageTagCoder aCoderEvent |
			aPackageTagCoder := (GtPharoPackageTagCoder forPackageTag: aTag)
				packageCoder: (GtPharoPackageCoder forPackage: aRealPackage).
			aCoderEvent := GtCoderToReplace new coder: aPackageTagCoder.
			anEvent currentTarget fireEvent: aCoderEvent.
			aCoderEvent isConsumed
				ifFalse: [ anEvent currentTarget phlow spawnTool: (GtReadyCoderTool coder: aCoderEvent coder) ] ]
]

{ #category : #'*GToolkit-Pharo-Coder-UI' }
GtTagDefinition >> tagEditor [
	^ GtCodeDefinitionSingleEditor new
		title: 'Tag';
		definition: self;
		getSelector: #name;
		setSelector: #name:;
		renameEvent: GtBehaviorTagRenamed;
		whenKey: BlKeyCombination primaryB do: [ :anEvent :aDefinition  | aDefinition browseFrom: anEvent ];
		whenKey: BlKeyCombination primaryC do: [ :anEvent :aDefinition  |
			Clipboard clipboardText: aDefinition name asString ];
		whenPrimaryClickDo: [ :anEvent :aDefinition | aDefinition browseFrom: anEvent ];
		containerName: self class tagEditorName
]

{ #category : #'*GToolkit-Pharo-Coder-UI' }
GtTagDefinition >> tagReader [
	^ GtCodeDefinitionSingleReader new
		title: 'Tag';
		definition: self;
		getSelector: #name;
		renameEvent: GtBehaviorTagRenamed;
		whenClickDo: [ :anEvent :aDefinition | aDefinition replaceFrom: anEvent ];
		whenPrimaryClickDo: [ :anEvent :aDefinition | aDefinition browseFrom: anEvent ]
]
