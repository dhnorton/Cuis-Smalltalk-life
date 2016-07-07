'From Cuis 4.2 of 25 July 2013 [latest update: #2829] on 6 July 2016 at 10:09:29.665138 pm'!
'Description The game of Life, an example of a cellular automaton, developed by Prof. John H. Conway at the University of Cambridge.

Gardner, Martin, "Mathematical Games", Scientific American, October 1970, February 1971
"Some Facts of Life", Byte Magazine, December 1978'!
!provides: 'Life' 1 0!
!classDefinition: #LifeModel category: #Life!
TextModel subclass: #LifeModel
	instanceVariableNames: 'shape cells cellIndex'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Life'!
!classDefinition: 'LifeModel class' category: #Life!
LifeModel class
	instanceVariableNames: ''!

!classDefinition: #LifeArray category: #Life!
Array2D subclass: #LifeArray
	instanceVariableNames: ''
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Life'!
!classDefinition: 'LifeArray class' category: #Life!
LifeArray class
	instanceVariableNames: ''!

!classDefinition: #GridCell category: #Life!
PluggableButtonMorph subclass: #GridCell
	instanceVariableNames: 'index offColor onColor'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Life'!
!classDefinition: 'GridCell class' category: #Life!
GridCell class
	instanceVariableNames: ''!

!classDefinition: #LifeView category: #Life!
SystemWindow subclass: #LifeView
	instanceVariableNames: 'runFlag stepDelay lines label periodN gridArray'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'Life'!
!classDefinition: 'LifeView class' category: #Life!
LifeView class
	instanceVariableNames: 'lines'!


!LifeModel commentStamp: 'dhn 6/25/2016 13:43' prior: 0!
A model for the game of Life, a two-dimensional cellular automaton.!

!LifeArray commentStamp: 'dhn 7/6/2016 15:24' prior: 0!
Avoid mental gymnastics while using Array2D, which uses backward coordinates.

Give access to #elements iVar.!

!GridCell commentStamp: 'dhn 6/25/2016 14:53' prior: 0!
A cell in the game of Life.!

!LifeView commentStamp: 'dhn 6/27/2016 16:25' prior: 0!
A view for the Life model, an example of a cellular automaton. The Life game was developed by Prof. John H. Conway at the University of Cambridge.

Gardner, Martin, "Mathematical Games", Scientific American, October 1970, February 1971
"Some Facts of Life", Byte Magazine, December 1978!

!LifeModel methodsFor: 'accessing' stamp: 'dhn 6/26/2016 16:07'!
cellIndex
	"Answer the value of cellIndex"

	^ cellIndex! !

!LifeModel methodsFor: 'accessing' stamp: 'dhn 6/25/2016 15:03'!
cellIndex: aNumber
	"Set the value of cellIndex"
	
	cellIndex _ aNumber! !

!LifeModel methodsFor: 'accessing' stamp: 'dhn 6/26/2016 08:26'!
cells
	"Answer the value of cells"
	^ cells! !

!LifeModel methodsFor: 'accessing' stamp: 'dhn 6/26/2016 08:28'!
cells: anObject
	"Set the value of cells"
	
	cells _ anObject! !

!LifeModel methodsFor: 'accessing' stamp: 'dhn 7/6/2016 16:00'!
clearGrid
	"Set the state of all cells to 0"
	
	(1 to: cells elements size) do: [:i | cells elements at: i put: 0].
	self triggerEvent: #stateChanged! !

!LifeModel methodsFor: 'operation' stamp: 'dhn 7/6/2016 17:58'!
nextState
	"Determine the next state of the cells"
	| future env sum |
	
	future _ cells copy.
	(1 to: cells height) do: [:row |
		(1 to: cells width) do: [:col | | pt |
			pt _ Point x: row y: col.
			env _ self surrounding:  pt.
			sum _ 0.
			env do: [:c | sum _ sum + (cells at: c)].
			(cells at: pt) = 1
				ifTrue: [
					(sum = 2 or: [sum = 3]) 
						ifTrue: [future at: pt put: 1]
						ifFalse: [future at: pt put: 0]]
				ifFalse: [
					sum = 3
						ifTrue: [future at: pt put: 1]
						ifFalse: [future at: pt put: 0]]]].
	
	cells elements: future elements.		
	self triggerEvent: #stateChanged.
	self triggerEvent: #period! !

!LifeModel methodsFor: 'initialization' stamp: 'dhn 7/6/2016 20:28'!
set: pattern at: coords
	"Load pattern into cells, starting at: coords, specifying the upper left cell location"
	"A pattern should be a collection of rows of equal length which are used to set initial state"
	| arr left depth |
	
	arr _ LifeArray height: pattern size width: pattern first size.
	arr fillWithArrayOfArrays: pattern.
	left _ coords second - 1 min: 0.
	depth _ (coords first - 1 min: 0) + arr height.
	(cells width >= (left + arr width) and: [cells height >= depth]) 
		ifTrue: [
			(0 to: (arr height - 1)) do: [:row | 
				(0 to: (arr width - 1)) do: [:col | 
					cells i: row + coords first j: col + coords second put: (arr i: row + 1 j: col + 1)]].
			self triggerEvent: #stateChanged]
		ifFalse: [nil inform: 'Life form too big for grid or 
not located high enough.']
! !

!LifeModel methodsFor: 'accessing' stamp: 'dhn 6/26/2016 11:48'!
shape
	"Answer the value of shape"
	
	^ shape! !

!LifeModel methodsFor: 'initialization' stamp: 'dhn 7/6/2016 15:53'!
shape: aPoint
	"Set the number of rows and columns of the grid"
	
	shape _ aPoint.
	cells _ LifeArray height: aPoint x width: aPoint y.
	self clearGrid! !

!LifeModel methodsFor: 'operation' stamp: 'dhn 6/26/2016 08:52'!
surrounding: aPoint
	"Answer the 3, 5, or 8 cells surrounding aPoint"
	| sur col top bot |
	
	col _ #(-1 0 1).
	sur _ OrderedCollection new.
	top _ aPoint x - 1.
	bot _ aPoint x + 1.
	
	top > 0 ifTrue: [
		col do: [:ea | sur add: (aPoint x - 1@(aPoint y + ea))]].
	
	bot < shape x ifTrue: [
		col do: [:ea | sur add: ((aPoint x + 1)@(aPoint y + ea))]].
	
	#(-1 1) do: [:ea | sur add: (aPoint x@(aPoint y + ea))].
	
	^ sur select: [:p | p y <= shape y and: [p y > 0]]
! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/2/2016 17:44'!
basic
	"Basic Shuttle"
	
	^ #(
		#(8 22)	"grid size := #(rows columns)"
		#(1 1) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 1 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0)
			#(1 1 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1 1)
			#(1 1 0 0 1 1 0 1 0 0 0 1 0 0 0 0 0 0 0 0 1 1)
			#(0 0 0 0 0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 1 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0)
			)
		#(250 502) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/6/2016 20:01'!
beacon
	"Beacon"
	
	^ #(
		#(5 6)		"grid size := #(rows columns)"
		#(1 2) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(1 1 0 0)
			#(1 0 0 0)
			#(0 0 0 1)
			#(0 0 1 1)
			)
		#(182 192) 	"extent := #(ver hor) for morph"
		)
		! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/2/2016 17:07'!
berloaf
	"Berloaflmeter, a period 7 object"
	
	^ #(
		#(11 11)	"grid size := #(rows columns)"
		#(1 1) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 0 0 0 0 1 0 0 0 0 0)
			#(0 0 0 0 1 0 1 0 0 0 0)
			#(0 0 0 1 0 1 0 1 0 1 1)
			#(0 0 0 1 0 0 0 1 0 1 1)
			#(1 1 0 1 1 0 0 1 0 0 0)
			#(1 0 1 0 0 0 0 1 0 0 0)
			#(0 0 0 1 1 1 1 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 1 1 0 0 0 0)
			#(0 0 0 0 0 1 1 0 0 0 0)
			)
		#(380 350) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/2/2016 17:17'!
bipole
	"Bipole"
	
	^ #(
		#(6 5)		"grid size := #(rows columns)"
		#(1 1) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(1 1 0 0 0)
			#(1 0 1 0 0)
			#(0 0 0 0 0)
			#(0 0 1 0 1)
			#(0 0 0 1 1)
			)
		#(216 160) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/6/2016 19:50'!
blinker
	"Blinker"
	
	^ #(
		#(4 5)		"grid size := #(rows columns)"
		#(2 2) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(1 1 1)
			)
		#(150 160) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/6/2016 20:04'!
clock
	"Clock"
	
	^ #(
		#(5 6)		"grid size := #(rows columns)"
		#(1 2) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 0 1 0)
			#(1 0 1 0)
			#(0 1 0 1)
			#(0 1 0 0)
			)
		#(182 192) 	"extent := #(ver hor) for morph"
		)
		! !

!LifeModel class methodsFor: 'documentation' stamp: 'dhn 6/28/2016 14:59'!
defaultLabel
	"Answer the label used when no life form has been loaded"
	
	^ 'The Game of Life'! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/2/2016 17:09'!
eaterBoundA
	"Eater Bound Oscillator A"
	
	^ #(
		#(18 20)	"grid size := #(rows columns)"
		#(1 1) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0)
			#(0 0 0 1 0 1 0 0 0 0 0 0 0 0 1 0 1 0 0 0)
			#(0 0 0 1 0 1 0 0 0 0 0 0 0 0 1 0 1 0 0 0)
			#(0 1 1 1 0 1 1 0 0 0 0 0 0 1 1 0 1 1 1 0)
			#(1 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 1)
			#(0 1 1 1 0 1 1 0 0 0 0 0 0 1 0 0 1 1 1 0)
			#(0 0 0 1 0 1 1 0 0 0 0 0 0 1 0 0 1 0 0 0)
			#(0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 1 1 1 1 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0)
			#(0 0 0 1 0 0 1 0 0 0 0 0 0 1 1 0 1 0 0 0)
			#(0 1 1 1 0 0 1 0 0 0 0 0 0 1 1 0 1 1 1 0)
			#(1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1)
			#(0 1 1 1 0 1 1 0 0 0 0 0 0 1 1 0 1 1 1 0)
			#(0 0 0 1 0 1 0 0 0 0 0 0 0 0 1 0 1 0 0 0)
			#(0 0 0 1 0 1 0 0 0 0 0 0 0 0 1 0 1 0 0 0)
			#(0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0)
			)
		#(380 350) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/2/2016 17:47'!
eaterBoundB
	"Eater Bound Oscillator B"
	
	^ #(
		#(14 12)	"grid size := #(rows columns)"
		#(1 1) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(1 0 0 0 0 0 0 0 0 0 0 0)
			#(1 1 1 0 0 0 0 0 0 0 0 0)
			#(0 0 0 1 0 0 0 0 0 0 0 0)
			#(0 0 1 1 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 1 0 0 0 0)
			#(0 0 0 0 1 1 1 1 0 0 0 0)
			#(0 0 0 0 1 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 1 1 0 0)
			#(0 0 0 0 0 0 0 0 1 0 0 0)
			#(0 0 0 0 0 0 0 0 0 1 1 1)
			#(0 0 0 0 0 0 0 0 0 0 0 1)
			)
		#(354 290) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/6/2016 21:12'!
engine
	"Switch engine, period 96"
	
	^ #(
		#(80 80)	"grid size := #(rows columns)"
		#(57 50) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1)
			)
		#(924 712) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/2/2016 17:20'!
flipflopA
	"Flipflop A"
	
	^ #(
		#(9 8)		"grid size := #(rows columns)"
		#(1 1) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 0 0 0 1 0 0 0)
			#(0 0 1 0 1 0 0 0)
			#(0 0 0 0 0 0 1 0)
			#(1 1 0 0 0 0 0 0)
			#(0 0 0 0 0 0 1 1)
			#(0 1 0 0 0 0 0 0)
			#(0 0 0 1 0 1 0 0)
			#(0 0 0 1 0 0 0 0)
			)
		#(252 207) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/6/2016 21:44'!
flipflopB
	"Flipflop B"
	
	^ #(
		#(10 6)	"grid size := #(rows columns)"
		#(2 1) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 1 1 1 0 0)
			#(0 0 0 0 0 0)
			#(1 1 0 0 1 0)
			#(0 0 0 0 0 0)
			#(0 1 0 0 1 1)
			#(0 0 0 0 0 0)
			#(0 0 1 1 1 0)
			)
		#(289 175) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/6/2016 20:15'!
flipflopC
	"Flipflop C"
	
	^ #(
		#(9 7)		"grid size := #(rows columns)"
		#(2 1) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 0 0 0 1 1 1)
			#(1 1 0 0 0 0 0)
			#(1 0 1 0 1 1 0)
			#(0 0 0 0 0 0 0)
			#(0 0 1 0 1 0 0)
			#(0 1 0 0 0 0 0)
			#(0 1 1 0 0 0 0)
			)
		#(275 211) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/2/2016 17:25'!
flipflopD
	"Flipflop D"
	
	^ #(
		#(8 6)		"grid size := #(rows columns)"
		#(1 1) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 0 1 0 0 0)
			#(0 0 1 0 1 0)
			#(1 0 0 0 0 0)
			#(0 1 1 1 1 1)
			#(1 0 0 0 0 0)
			#(0 0 1 0 1 0)
			#(0 0 1 0 0 0)
			)
		#(288 205) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/6/2016 20:43'!
glider
	"Glider"
	
	^ #(
		#(15 14)	"grid size := #(rows columns)"
		#(12 2) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(1 1 1)
			#(0 0 1)
			#(0 1 0)
			)
		#(377 316) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/6/2016 21:00'!
gliderGun
	"Glider gun, period 30"
	
	^ #(
		#(27 40)	"grid size := #(rows columns)"
		#(18 2) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 1 1 1 1 1 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0)
			#(1 1 0 0 0 0 0 1 1 1 0 0 0 0 0 1 0 0 1 1 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0)
			#(1 1 0 0 0 0 0 0 1 1 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1 1)
			#(0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 1 1)
			#(0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0)
			)
		#(450 542) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/6/2016 20:19'!
hiveEater
	"Block devours beehive"
	
	^ #(
		#(6 7)		"grid size := #(rows columns)"
		#(2 1) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 0 0 0 1 1 0)
			#(1 1 0 1 0 0 1)
			#(1 1 0 0 1 1 0)
			)
		#(230 235) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/6/2016 20:35'!
mazing
	"Mazing, a period 4 pulsator"
	
	^ #(
		#(10 9)		"grid size := #(rows columns)"
		#(2 2) 		"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 0 1 0 0 0 0)
			#(0 1 0 1 0 0 0)
			#(0 0 0 0 0 0 0)
			#(1 1 0 0 0 1 0)
			#(1 0 0 0 0 0 1)
			#(0 0 0 1 0 1 0)
			#(0 0 1 1 0 0 0)
			)
		#(303 254) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'database' stamp: 'dhn 7/2/2016 10:23'!
menuLines
	"Answer where to place lines in the Life Forms menu"
	| nm ln |
	
	nm _ OrderedCollection new.
	self patternNames do: [:ea | nm add: ea first].
	
	ln _ OrderedCollection new.
	#(
		'Tripole' 
		'Period 2 Oscillator'
		'Period 3 Eater' 
		'Unix' 
		'Period 9 Object' 
		'Twin Bees Shuttle'
		'Eater Bound B'
		'Heavy Spaceship'
		'Period 6 Oscillator'
		'New Gun'
	) do: [:ea | ln add: (nm findFirst: [:s | s = ea])].
	
	^ ln! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/2/2016 17:38'!
mitOsc
	"MIT Oscillator, a period 3 object"
	
	^ #(
		#(9 9)		"grid size := #(rows columns)"
		#(1 1) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 0 0 1 1 0 0 0 0)
			#(0 0 0 1 0 1 0 1 1)
			#(0 0 0 0 0 1 0 1 1)
			#(0 0 0 0 0 1 0 0 0)
			#(0 0 1 0 0 1 0 0 0)
			#(0 1 0 1 1 0 0 0 0)
			#(0 1 0 0 0 0 0 0 0)
			#(1 1 0 0 0 0 0 0 0)
			)
		#(264 243) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/6/2016 21:04'!
newGun
	"Period 46 glider gun"
	
	^ #(
		#(40 40)	"grid size := #(rows columns)"
		#(4 7) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1)
			#(0 0 0 0 0 1 1 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(1 1 1 0 0 0 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(1 0 0 1 0 1 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(1 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 1 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 1 1 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(1 1 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(1 1 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			)
		#(700 586) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'database' stamp: 'dhn 7/2/2016 15:05'!
patternNames
	"Translate a menu list item to a class method selector for the pattern"
	^ #(
		('Blinker' 					#blinker)
		('Beacon' 					#beacon)
		('Clock' 					#clock)
		('Toad' 					#toad)
		('Bipole' 					#bipole)
		('Tripole' 					#tripole)
		('Flipflop A' 				#flipflopA)
		('Flipflop B' 				#flipflopB)
		('Flipflop C' 				#flipflopC)
		('Flipflop D' 				#flipflopD)
		('Period 2 Oscillator' 	#period2)
		('Period 6 Eater' 			#period6)
		('Block Eats Beehive' 	#hiveEater)
		('Period 3 Eater' 			#period3)
		('Pulsar' 					#pulsar)
		('Tumbler' 				#tumbler)
		('Period 8 Inductor' 		#unnamed1)
		('Pentadecathlon' 		#pentadec)
		('Mazing' 					#mazing	)
		('Unix' 						#unix)
		('MIT Oscillator' 			#mitOsc	)
		('Berloaferlmeter' 		#berloaf)
		('Period 8 Object' 		#unnamed2)
		('Wavefront' 				#wavefront)
		('Period 5 Oscillator' 	#unnamed3)
		('Period 9 Object' 		#unnamed4)
		('Basic Shuttle' 			#basic)
		('Twin Bees Shuttle' 		#twinBees)
		('Eater Bound A' 			#eaterBoundA)
		('Eater Bound B' 			#eaterBoundB)
		('Glider' 					#glider)
		('Light Spaceship' 		#space1)
		('Medium Spaceship' 	#space2)
		('Heavy Spaceship' 		#space3)
		('Period 52 Eater' 		#period52)
		('Period 6 Oscillator' 	#period6O)
		('Glider Gun' 				#gliderGun)
		('New Gun' 				#newGun)
		('Switch Engine' 			#engine)
	)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/6/2016 20:32'!
pentadec
	"The pentadecathlon pulsar"
	
	^ #(
		#(10 18)		"grid size := #(rows columns)"
		#(4 5) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 0 1 0 0 0 0 1 0 0)
			#(1 1 0 1 1 1 1 0 1 1)
			#(0 0 1 0 0 0 0 1 0 0)
			)
		#(266 349) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/2/2016 16:36'!
period2
	"Period 2 Oscillator"
	
	^ #(
		#(15 14)	"grid size := #(rows columns)"
		#(1 1) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 0 0 0 1 1 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 1 0 0 0 0 0 0 0 0)
			#(0 0 0 0 1 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 1 1 1 1 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 1 0 1 1 0 1)
			#(0 0 0 0 1 1 1 0 1 0 1 0 1 1)
			#(0 0 0 1 0 0 0 0 1 0 1 0 0 0)
			#(0 0 0 1 0 1 0 0 0 0 1 0 0 0)
			#(1 1 0 1 0 1 0 1 1 1 0 0 0 0)
			#(1 0 1 1 0 1 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 1 1 1 1 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 1 0 0 0 0)
			#(0 0 0 0 0 0 0 0 1 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 1 1 0 0 0 0)
			)
		#(380 350) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/6/2016 20:25'!
period3
	"Period 3 eater"
	
	^ #(
		#(8 8)		"grid size := #(rows columns)"
		#(1 2) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 0 0 0 0 1 1)
			#(0 0 0 0 0 1 1)
			#(0 0 0 0 0 1 1)
			#(0 0 1 1 0 0 0)
			#(0 1 0 1 0 0 0)
			#(0 1 0 0 0 0 0)
			#(1 1 0 0 0 0 0)
			)
		#(279 261) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/6/2016 20:54'!
period52
	"Period 52 eater"
	
	^ #(
		#(19 21)	"grid size := #(rows columns)"
		#(2 2) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 1 1 1 0 0)
			#(1 1 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0)
			#(0 1 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0)
			#(0 1 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 1 0 1 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 1 1 0 0 0 1 1 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 1 0)
			#(0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 1 0)
			#(0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 1 1)
			#(0 0 1 1 1 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			)
		#(380 350) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/2/2016 17:27'!
period6
	"Period 6 eater"
	
	^ #(
		#(11 9)	"grid size := #(rows columns)"
		#(1 1) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 0 0 0 1 0 0 0 0)
			#(0 0 0 1 0 1 0 0 0)
			#(0 0 0 1 0 1 0 0 0)
			#(0 1 1 1 0 1 1 0 0)
			#(1 0 0 0 0 0 0 0 0)
			#(0 1 1 1 0 1 1 0 0)
			#(0 0 0 1 0 1 1 0 0)
			#(0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 1 1)
			#(0 0 0 0 0 0 0 1 1)
			)
		#(319 259) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/6/2016 20:57'!
period6O
	"Period 6 oscillator"
	
	^ #(
		#(23 19)	"grid size := #(rows columns)"
		#(2 2) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 1 0 1 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 1 0 1 0 0 0)
			#(0 0 0 1 1 0 0 0 0 1 1 0 1 1 1 0)
			#(0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 1)
			#(0 0 0 0 0 1 0 0 0 1 1 0 1 1 1 0)
			#(0 0 0 0 0 1 1 0 0 1 1 0 1 0 0 0)
			#(0 0 0 1 1 0 0 1 0 0 0 0 0 0 0 0)
			#(0 0 0 0 1 0 1 1 0 0 0 0 0 0 0 0)
			#(0 1 0 0 1 0 0 0 0 0 0 0 0 0 0 0)
			#(1 0 1 0 1 0 0 0 0 0 0 0 0 0 0 0)
			#(0 1 0 0 1 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 1 0 1 1 0 0 0 0 0 0 0 0)
			#(0 0 0 1 1 0 0 1 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 1 1 0 0 1 1 0 1 0 0 0)
			#(0 0 0 0 0 1 0 0 0 1 1 0 1 1 1 0)
			#(0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 1)
			#(0 0 0 1 1 0 0 0 0 1 1 0 1 1 1 0)
			#(0 0 0 0 0 0 0 0 0 0 1 0 1 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 1 0 1 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0)
			)
		#(528 366) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/6/2016 21:42'!
pulsar
	"Pulsar, a period 3 inductor"
	
	^ #(
		#(16 15)	"grid size := #(rows columns)"
		#(2 1) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 0 0 1 1 1 0 0 0 1 1 1 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 1 0 0 0 0 1 0 1 0 0 0 0 1 0)
			#(0 1 0 0 0 0 1 0 1 0 0 0 0 1 0)
			#(0 1 0 0 0 0 1 0 1 0 0 0 0 1 0)
			#(0 0 0 1 1 1 0 0 0 1 1 1 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 1 1 1 0 0 0 1 1 1 0 0 0)
			#(0 1 0 0 0 0 1 0 1 0 0 0 0 1 0)
			#(0 1 0 0 0 0 1 0 1 0 0 0 0 1 0)
			#(0 1 0 0 0 0 1 0 1 0 0 0 0 1 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 1 1 1 0 0 0 1 1 1 0 0 0)
			)
		#(380 350) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/6/2016 21:41'!
space1
	"Lightweight Spaceship"
	
	^ #(
		#(6 40)	"grid size := #(rows columns)"
		#(2 2) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 1 1 1 1)
			#(1 0 0 0 1)
			#(0 0 0 0 1)
			#(1 0 0 1 0)
			)
		#(164 705) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/6/2016 20:49'!
space2
	"Middleweight Spaceship"
	
	^ #(
		#(7 40)	"grid size := #(rows columns)"
		#(2 2) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 1 1 1 1 1)
			#(1 0 0 0 0 1)
			#(0 0 0 0 0 1)
			#(1 0 0 0 1 0)
			#(0 0 1 0 0 0)
			)
		#(228 946) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/6/2016 20:51'!
space3
	"Heavyweight Spaceship"
	
	^ #(
		#(7 40)		"grid size := #(rows columns)"
		#(2 2) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 1 1 1 1 1 1)
			#(1 0 0 0 0 0 1)
			#(0 0 0 0 0 0 1)
			#(1 0 0 0 0 1 0)
			#(0 0 1 1 0 0 0)
			)
		#(186 727) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/6/2016 20:06'!
toad
	"Toad"
	
	^ #(
		#(5 6)		"grid size := #(rows columns)"
		#(1 2) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 1 1 0)
			#(1 0 0 0)
			#(0 0 0 1)
			#(0 1 1 0)
			)
		#(182 192) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/2/2016 17:18'!
tripole
	"Tripole"
	
	^ #(
		#(7 6)		"grid size := #(rows columns)"
		#(1 1) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(1 1 0 0 0 0)
			#(1 0 1 0 0 0)
			#(0 0 0 0 0 0)
			#(0 0 1 0 1 0)
			#(0 0 0 0 0 1)
			#(0 0 0 0 1 1)
			)
		#(203 160) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/6/2016 21:40'!
tumbler
	"Tumbler, a period 14 inductor"
	
	^ #(
		#(9 9)		"grid size := #(rows columns)"
		#(2 1) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 0 1 1 0 1 1 0 0)
			#(0 0 1 1 0 1 1 0 0)
			#(0 0 0 1 0 1 0 0 0)
			#(0 1 0 1 0 1 0 1 0)
			#(0 1 0 1 0 1 0 1 0)
			#(0 1 1 0 0 0 1 1 0)
			)
		#(267 264) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/6/2016 21:38'!
twinBees
	"Twin Bees Shuttle"
	
	^ #(
		#(14 29)	"grid size := #(rows columns)"
		#(2 1) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(1 1 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1)
			#(1 1 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1)
			#(0 0 0 0 0 0 0 0 0 0 1 1 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 0 1 1 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(1 1 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1)
			#(1 1 0 0 0 0 0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 1 1)
			#(0 0 0 0 0 0 0 0 0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0)
			)
		#(380 615) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/6/2016 20:38'!
unix
	"Unix, a period 6 pulsator"
	
	^ #(
		#(10 10)	"grid size := #(rows columns)"
		#(1 2) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 1 1 0 0 0 0 0)
			#(0 1 1 0 0 0 0 0)
			#(0 0 0 0 0 0 0 0)
			#(0 1 0 0 0 0 0 0)
			#(1 0 1 0 0 0 0 0)
			#(1 0 0 1 0 0 1 1)
			#(0 0 0 0 1 0 1 1)
			#(0 0 1 1 0 0 0 0)
			)
		#(263 237) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/2/2016 17:33'!
unnamed1
	"Unnamed period 8 inductor"
	
	^ #(
		#(13 21)	"grid size := #(rows columns)"
		#(1 1) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 0 0 0 1 1 0 0 0 0 0 0 0 0 0 1 1 0 0 0 0)
			#(0 0 0 1 0 1 0 0 0 0 0 0 0 0 0 1 0 1 0 0 0)
			#(0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0)
			#(1 1 0 1 1 0 0 0 0 0 0 0 0 0 0 0 1 1 0 1 1)
			#(1 1 0 1 0 0 0 1 1 0 0 0 1 1 0 0 0 1 0 1 1)
			#(0 0 0 1 0 1 0 0 0 1 0 1 0 0 0 1 0 1 0 0 0)
			#(0 0 0 1 0 1 0 0 0 1 0 1 0 0 0 1 0 1 0 0 0)
			#(0 0 1 1 0 1 0 0 0 1 0 1 0 0 0 1 0 1 1 0 0)
			#(0 0 0 1 0 0 1 1 1 0 0 0 1 1 1 0 0 1 0 0 0)
			#(0 0 0 1 0 0 0 0 0 0 0 0 0 0 0 0 0 1 0 0 0)
			#(0 0 0 0 1 1 1 0 0 0 0 0 0 0 1 1 1 0 0 0 0)
			#(0 0 0 0 0 0 1 0 0 0 0 0 0 0 1 0 0 0 0 0 0)
			)
		#(309 373) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/2/2016 17:07'!
unnamed2
	"Unnamed period 8 object"
	
	^ #(
		#(13 15)	"grid size := #(rows columns)"
		#(1 1) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 0 0 0 1 1 0 0 0 1 1 0 0 0 0)
			#(0 0 0 1 0 1 0 0 0 1 0 1 0 0 0)
			#(0 0 0 1 0 0 0 0 0 0 0 1 0 0 0)
			#(1 1 0 1 1 0 0 0 0 0 1 1 0 1 1)
			#(1 1 0 1 0 0 0 1 0 0 0 1 0 1 1)
			#(0 0 0 1 0 1 0 0 0 1 0 1 0 0 0)
			#(0 0 0 1 0 1 0 0 0 1 0 1 0 0 0)
			#(0 0 1 1 0 1 0 0 0 1 0 1 1 0 0)
			#(0 0 0 1 0 0 1 1 1 0 0 1 0 0 0)
			#(0 0 0 1 0 0 0 0 0 0 0 1 0 1 0)
			#(0 0 0 0 1 1 1 0 0 0 0 0 1 1 0)
			#(0 0 0 0 0 0 1 0 0 0 0 0 0 0 0)
			)
		#(380 350) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/2/2016 17:42'!
unnamed3
	"Unnamed period 5 oscillator"
	
	^ #(
		#(16 13)	"grid size := #(rows columns)"
		#(1 1) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 0 0 0 0 0 0 0 0 1 1 0 0)
			#(0 0 0 0 0 0 0 0 1 0 1 0 0)
			#(0 0 1 1 0 0 0 0 1 0 0 0 0)
			#(0 0 0 1 0 0 1 1 0 1 0 0 0)
			#(0 0 0 1 0 1 0 0 0 1 0 0 0)
			#(1 1 0 1 0 1 0 1 0 1 0 1 1)
			#(1 1 0 1 0 1 0 1 0 1 0 1 1)
			#(0 0 0 1 0 0 0 0 0 1 0 0 0)
			#(1 1 0 1 0 0 0 0 1 1 0 1 1)
			#(1 1 0 1 0 0 1 0 0 1 0 1 1)
			#(0 0 0 1 0 1 0 1 0 1 0 0 0)
			#(0 0 0 1 0 0 1 1 0 1 0 0 0)
			#(0 0 1 1 0 0 0 0 1 0 0 0 0)
			#(0 0 0 0 0 0 0 0 1 0 1 0 0)
			#(0 0 0 0 0 0 0 0 0 1 1 0 0)
			)
		#(380 310) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/2/2016 17:08'!
unnamed4
	"Unnamed period 9 object"
	
	^ #(
		#(15 14)	"grid size := #(rows columns)"
		#(1 1) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 0 0 0 0 0 0 0 0 0 1 1 0 0)
			#(0 0 0 0 0 0 1 1 0 0 1 0 0 0)
			#(0 0 0 0 0 0 1 0 1 0 1 0 0 0)
			#(0 0 0 0 0 0 0 1 0 0 1 0 1 1)
			#(0 0 0 0 0 0 0 0 0 0 1 0 1 1)
			#(0 0 0 0 0 0 0 0 0 0 1 0 0 0)
			#(0 1 1 0 0 0 0 0 1 0 1 0 0 0)
			#(0 1 0 1 0 0 0 0 1 1 0 0 0 0)
			#(0 0 1 0 0 0 1 1 0 0 0 0 0 0)
			#(0 0 0 0 0 0 0 1 0 0 0 0 0 0)
			#(1 1 1 1 1 1 1 0 0 0 0 0 0 0)
			#(1 0 0 0 0 0 0 0 0 0 0 0 0 0)
			#(0 0 0 1 1 0 0 0 0 0 0 0 0 0)
			#(0 0 0 1 1 0 0 0 0 0 0 0 0 0)
			)
		#(380 350) 	"extent := #(ver hor) for morph"
		)! !

!LifeModel class methodsFor: 'canned patterns' stamp: 'dhn 7/2/2016 17:41'!
wavefront
	"Wavefront, a period 4 object"
	
	^ #(
		#(14 13)	"grid size := #(rows columns)"
		#(1 1) 	"position := #(x y) to load pattern"
		
		#(	"the pattern"
			#(0 0 0 0 0 0 0 0 1 1 0 0 0)
			#(0 0 0 0 0 0 0 0 1 0 0 0 0)
			#(0 0 0 0 0 0 0 0 0 1 0 0 0)
			#(0 0 0 0 0 0 0 0 1 1 0 0 0)
			#(0 0 0 0 0 1 1 0 0 0 1 1 0)
			#(0 0 0 0 1 0 0 1 1 1 0 0 1)
			#(0 0 0 0 1 0 0 0 0 0 1 1 0)
			#(0 0 0 0 0 1 0 0 0 1 0 0 0)
			#(1 1 0 1 0 1 0 0 0 1 0 0 0)
			#(1 0 1 1 0 1 0 1 1 0 0 0 0)
			#(0 0 0 0 1 0 1 0 0 0 0 0 0)
			#(0 0 0 0 1 0 1 0 0 0 0 0 0)
			#(0 0 0 0 0 1 0 0 0 0 0 0 0)
			)
		#(380 322) 	"extent := #(ver hor) for morph"
		)! !

!LifeArray methodsFor: 'accessing' stamp: 'dhn 7/6/2016 15:41'!
at: aPoint
	"
	Answer the element at aPoint, where:
		row := aPoint x
		col := aPoint y
	"
	
	^ self i: aPoint x j: aPoint y! !

!LifeArray methodsFor: 'accessing' stamp: 'dhn 7/6/2016 15:42'!
at: aPoint put: anObject
	"
	Set the element at aPoint to anObject, where:
		row := aPoint x
		col := aPoint y
	"
	
	^ self i: aPoint x j: aPoint y put: anObject! !

!LifeArray methodsFor: 'accessing' stamp: 'dhn 7/6/2016 14:25'!
elements
	"Answer the value of elements"
	
	^ elements! !

!LifeArray methodsFor: 'accessing' stamp: 'dhn 7/6/2016 14:26'!
elements: anObject
	"Set the value of elements"
	
	elements _ anObject! !

!GridCell methodsFor: 'accessing' stamp: 'dhn 6/26/2016 08:48'!
index
	"Answer the value of index"
	
	^ index! !

!GridCell methodsFor: 'accessing' stamp: 'dhn 6/25/2016 14:55'!
index: anObject
	"Set the value of index"

	index _ anObject! !

!GridCell methodsFor: 'initialization' stamp: 'dhn 7/6/2016 15:44'!
initialize

	super initialize.
	offColor _ self color.
	onColor _ Color lightGreen.
	self setProperty: #'handlesMouseDown:' toValue: true
! !

!GridCell methodsFor: 'event handling' stamp: 'dhn 6/30/2016 15:58'!
mouseButton2Down: event localPosition: point 
	"Bring up menu for cell"

	model triggerEvent: #gridMenu
! !

!GridCell methodsFor: 'accessing' stamp: 'dhn 6/25/2016 14:55'!
offColor
	"Answer the value of offColor"

	^ offColor! !

!GridCell methodsFor: 'accessing' stamp: 'dhn 6/25/2016 14:56'!
onColor
	"Answer the value of onColor"

	^ onColor! !

!GridCell methodsFor: 'event handling' stamp: 'dhn 7/6/2016 16:22'!
performAction
	"Identify the cell that was pressed; toggle its state and color"

	model cellIndex: index.
	model cells at: index put: 
		((model cells at: index) = 0 ifTrue: [1] ifFalse: [0]).
	self reflectState.
	super performAction! !

!GridCell methodsFor: 'accessing' stamp: 'dhn 7/6/2016 16:21'!
reflectState
	"Set color based on the state of the cell at index"
	
	self color: ((model cells at: index) = 1 ifTrue: [onColor] ifFalse: [offColor])
! !

!LifeView methodsFor: 'initialization' stamp: 'dhn 7/6/2016 17:10'!
buildMorphicWindow
	"Set up the grid in a system window"
	
	gridArray _ model cells copy.
	(1 to: model shape x) do: [:ea |
		self layoutMorph
			addMorph: (
				LayoutMorph newRow
					separation: 2@2;
					 addAllMorphs: (self row: ea length: model shape y))].
				
	model when: #gridMenu send: #menuMain to: self.
	model when: #stateChanged send: #stateChanged to: self.
	model when: #period send: #updateTitle to: self! !

!LifeView methodsFor: 'menu' stamp: 'dhn 7/4/2016 15:59'!
experiment
	"Open a clean sheet at a scale and extent"
	 | xy grid jk ext |
	
	xy _ FillInTheBlankMorph request: 'Grid dimensions (h x w)?' initialAnswer: '30x40'.
	xy ifNotEmpty: [ | inp |
		inp _ xy findTokens: 'x' keep: ($0 to: $9).
		grid _ {inp first asNumber. inp second asNumber}.
		jk _ FillInTheBlankMorph request: 'Window extent (h x w)?' initialAnswer: '500x700'.
		jk 
			ifNotEmpty: [ | dat win |
				dat _ jk findTokens: 'x' keep: ($0 to: $9).
				ext _ {dat second asNumber. dat first asNumber}.
				win _ self class rows: grid first cols: grid second.
				win extentAndPosition: (Point x: ext first y: ext second).
				win setLabel: 'Experiment'.
				win label: 'Experiment'.
				]
			ifEmpty: [^ nil]
		].! !

!LifeView methodsFor: 'initialization' stamp: 'dhn 7/4/2016 15:57'!
extentAndPosition: aPoint
	"Set the extent of the receiver and center it in the display"
	
	self 
		morphExtent: aPoint;
		morphPosition: Display center - (self morphExtent / 2.0)
	! !

!LifeView methodsFor: 'initialization' stamp: 'dhn 6/28/2016 11:12'!
initialize

	super initialize.
	runFlag _ false.
	stepDelay _ 500
! !

!LifeView methodsFor: 'label' stamp: 'dhn 7/2/2016 09:30'!
label
	"Answer the value of label"
	
	^ label! !

!LifeView methodsFor: 'label' stamp: 'dhn 7/1/2016 22:10'!
label: aString
	"Set the value of label"
	
	label  _ aString! !

!LifeView methodsFor: 'menu' stamp: 'dhn 6/28/2016 21:58'!
lines: anObject
	"Set the value of lines"
	
	lines _ anObject! !

!LifeView methodsFor: 'menu' stamp: 'dhn 7/4/2016 16:00'!
loadPattern
	"Load a life form selected from a menu"
	| items n arr siz nww ext |
	
	items _ String streamContents: [:s | 
		model class patternNames do: [:i | s nextPutAll: i first asString; newLine]].
	n _ (PopUpMenu labels: items lines: lines) startUpWithCaption: 'Life Forms'.
	(n > 0 and: [n < (model class patternNames size + 1)]) ifTrue: [
		arr _ model class perform: (model class patternNames at: n) second.

		"spawn another version of the view, then delete this one"
		siz _ arr first. "size of the next view"
		nww _ self class rows: siz first cols: siz second. "open the next view"
		nww model set: arr third at: arr second. 	"load the chosen life form into the next view"
		nww label: (model class patternNames at: n) first.
		nww setLabel: nww label.
		ext _ arr fourth.
		nww extentAndPosition: (Point x: ext second y: ext first).
		self delete "delete old view"]! !

!LifeView methodsFor: 'menu' stamp: 'dhn 7/2/2016 11:47'!
menuMain
	"Answer the main pop-up menu"
	
	| aMenu |
	aMenu _ MenuMorph new defaultTarget: self.
	
	aMenu addList: #(
		('Run/Pause'				pauseResume)
		('Step'						takeAStep)
		('Stop'						sayStop)
		('Clear'					sayClear)
		('Load...'					loadPattern)
		('Experiment...'			experiment)
		).

	aMenu openInHand! !

!LifeView methodsFor: 'menu' stamp: 'dhn 6/28/2016 11:13'!
pauseResume
	"Toggle the run flag"
	
	(runFlag _ runFlag not)
		ifTrue: [self sayRun]
		ifFalse: [self sayStop]! !

!LifeView methodsFor: 'label' stamp: 'dhn 7/1/2016 22:06'!
periodN
	"Answer the value of period"
	
	periodN ifNil: [periodN _ 0].
	^ periodN! !

!LifeView methodsFor: 'label' stamp: 'dhn 7/1/2016 22:07'!
periodN: aNumber
	"Set the value of periodN"
	
	periodN _ aNumber! !

!LifeView methodsFor: 'initialization' stamp: 'dhn 7/6/2016 17:11'!
row: aRow length: aNumber
	"Answer aNumber of cells for aRow"
	| col morph |

	col _ OrderedCollection new.
	(1 to: aNumber) do: [:ea |
			morph _ GridCell model: model action: nil.
			morph
				index: aRow@ea;
				roundButtonStyle: false;
				layoutSpec: (LayoutSpec proportionalWidth: 0.2).
				gridArray i: aRow j: ea put: morph.
				col addFirst: morph].
	^ col! !

!LifeView methodsFor: 'menu' stamp: 'dhn 6/28/2016 15:32'!
sayClear
	"Clear the grid"
	
	model clearGrid.
	self setLabel: model class defaultLabel! !

!LifeView methodsFor: 'menu' stamp: 'dhn 6/28/2016 11:22'!
sayRun
	"Tell the model to run"
	
	self startSteppingStepTime: stepDelay! !

!LifeView methodsFor: 'menu' stamp: 'dhn 6/28/2016 11:16'!
sayStop
	"Tell the model to stop run ning"
	
	runFlag _ false.
	self stopStepping! !

!LifeView methodsFor: 'change reporting' stamp: 'dhn 7/6/2016 17:15'!
stateChanged
	"Cause all the grid cells to reflect the state of the model"
	
	gridArray elements do: [:ea | ea reflectState]! !

!LifeView methodsFor: 'menu' stamp: 'dhn 6/27/2016 15:10'!
takeAStep
	"Do one cycle"
	
	model nextState! !

!LifeView methodsFor: 'label' stamp: 'dhn 7/1/2016 22:04'!
updateTitle
	"Append the period count to the title"
	
	self periodN: self periodN + 1.
	self setLabel: (String streamContents: [:str |
		str
			nextPutAll: label;
			nextPut: $ ;
			nextPutAll: periodN asString])! !

!LifeView class methodsFor: 'instance creation' stamp: 'dhn 6/29/2016 15:35'!
cellSize
	"Answer the target size for a grid cell"
	
	^ 30! !

!LifeView class methodsFor: 'examples' stamp: 'dhn 7/6/2016 21:59'!
example
	"
	LifeView example
	"
	| life |

	life _ LifeView open: 8@9.
	life label: 'LIFE Example'
! !

!LifeView class methodsFor: 'examples' stamp: 'dhn 7/6/2016 22:01'!
example1
	"The pentadecathlon, a pulsar of period 15
	
	LifeView example1.
	"
	| view |
	
	view _ LifeView open: 10@18.
	view label: 'A LIFE Example'.
	view model set: view model class pentadec third at: #(4 5).
	view sayRun
! !

!LifeView class methodsFor: 'instance creation' stamp: 'dhn 7/6/2016 13:19'!
open: aPoint
	"Set up a game of Life on a grid of aPoint shape"
	| mod win xx yy |
	
	mod _ LifeModel new.
	mod shape: aPoint.
	win _ self open: mod label: mod class defaultLabel.
	xx _ 2 + self cellSize * aPoint y.
	yy _ 2 + self cellSize * (aPoint x) + 22.
	win extentAndPosition: (Point x: xx y: yy).
	win lines: mod class menuLines.
	win when: #morphicStep evaluate: [ :unused | mod nextState].
	^ win! !

!LifeView class methodsFor: 'instance creation' stamp: 'dhn 7/4/2016 15:58'!
rows: rows cols: cols
	"Set up a game of Life on a grid of rows x cols"
	| mod win xx yy |
	
	mod _ LifeModel new shape: rows@cols.
	win _ self open: mod label: mod class defaultLabel.
	xx _ 2 + self cellSize * cols.
	yy _ 2 + self cellSize * rows + 22.
	win extentAndPosition: (Point x: xx y: yy).
	win lines: mod class menuLines.
	win when: #morphicStep evaluate: [ :unused | mod nextState].
	^ win! !
