Class {
	#name : #GtProcessCoder,
	#superclass : #GtPharoMethodsCoder,
	#instVars : [
		'session'
	],
	#category : #'GToolkit-Pharo-Coder-Coders'
}

{ #category : #'instance creation' }
GtProcessCoder class >> forDebugSession: aDebugSession [
	^ self new
		forDebugSession: aDebugSession;
		yourself
]

{ #category : #'instance creation' }
GtProcessCoder class >> forProcess: aProcess [
	^ self new
		forProcess: aProcess;
		yourself
]

{ #category : #'initialize-release' }
GtProcessCoder >> forDebugSession: aDebugSession [
	session := aDebugSession.
	self updateCoders
]

{ #category : #'initialize-release' }
GtProcessCoder >> forProcess: aProcess [
	self forDebugSession: (DebugSession 
		named: 'Debug ' , aProcess name 
		on: aProcess 
		startedAt: aProcess suspendedContext)
]

{ #category : #testing }
GtProcessCoder >> isSuspended [
	^ session process notNil and: [ 
		session process isSuspended and: [ 
			session process isTerminating not and: [ 
				session process isTerminated not ] ] ]
]

{ #category : #updating }
GtProcessCoder >> updateCoders [
	| context firstContext coder newCoders |
	self isSuspended
		ifTrue: [ coders := coders asOrderedCollection reject: [ :each | each isDead ].
			firstContext := coders isEmpty
				ifTrue: [ nil ]
				ifFalse: [ coders first context ].
			context := session process suspendedContext.
			newCoders := OrderedCollection new.
			[ context notNil and: [ context ~~ firstContext ] ]
				whileTrue: [ coder := GtPharoMethodContextCoder forContext: context session: session.
					coder announcer weak
						when: GtCoderRefreshStackAnnouncement
						send: #updateCoders
						to: self.
					newCoders add: coder.
					context := context sender ].
			coders addAllFirst: newCoders ]
		ifFalse: [ coders := OrderedCollection new ].
	self
		announce:
			(GtCodersCodersChanged new
				coders: self;
				yourself)
]
