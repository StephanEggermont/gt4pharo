Class {
	#name : #GtBehaviorDefinitionCoderExamples,
	#superclass : #Object,
	#category : #'GToolkit-Pharo-Coder-Examples'
}

{ #category : #'instance creation' }
GtBehaviorDefinitionCoderExamples >> forClass [
	<gtExample>
	| aCoder |

	aCoder := GtPharoBehaviorDefinitionCoder forBehavior: GtBehaviorCoderDummyClass.

	self assert: aCoder behavior equals: GtBehaviorCoderDummyClass.
	self assert: aCoder definition notNil.

	^ aCoder
]

{ #category : #'instance creation' }
GtBehaviorDefinitionCoderExamples >> forMetaclass [
	<gtExample>
	| aCoder |

	aCoder := GtPharoBehaviorDefinitionCoder forBehavior: GtBehaviorCoderDummyClass class.

	self assert: aCoder behavior equals: GtBehaviorCoderDummyClass class.
	self assert: aCoder definition notNil.

	^ aCoder
]

{ #category : #'instance creation' }
GtBehaviorDefinitionCoderExamples >> forTrait [
	<gtExample>
	| aCoder |

	aCoder := GtPharoBehaviorDefinitionCoder forBehavior: TGtBehaviorCoderDummyTrait.

	self assert: aCoder behavior equals: TGtBehaviorCoderDummyTrait.
	self assert: aCoder definition notNil.

	^ aCoder
]
