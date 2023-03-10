'From Cuis 5.0 [latest update: #4963] on 24 November 2021 at 10:42:49 am'!
'Description '!
!provides: 'AnimatedGIF' 1 2!
SystemOrganization addCategory: 'AnimatedGIF'!


!classDefinition: #GIFReadWriter category: 'AnimatedGIF'!
ImageReadWriter subclass: #GIFReadWriter
	instanceVariableNames: 'width height bitsPerPixel colorPalette rowByteSize xpos ypos pass interlace transparentIndex localColorTable loopCount offset frames canvasWidth canvasHeight backgroundColorIndex comment'
	classVariableNames: 'Extension ImageSeparator Terminator'
	poolDictionaries: ''
	category: 'AnimatedGIF'!
!classDefinition: 'GIFReadWriter class' category: 'AnimatedGIF'!
GIFReadWriter class
	instanceVariableNames: ''!

!classDefinition: #AnimatedImageMorph category: 'AnimatedGIF'!
WidgetMorph subclass: #AnimatedImageMorph
	instanceVariableNames: 'forms currentIdx delay'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AnimatedGIF'!
!classDefinition: 'AnimatedImageMorph class' category: 'AnimatedGIF'!
AnimatedImageMorph class
	instanceVariableNames: ''!

!classDefinition: #AnimatedImageFrame category: 'AnimatedGIF'!
Object subclass: #AnimatedImageFrame
	instanceVariableNames: 'form delay disposal offset'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AnimatedGIF'!
!classDefinition: 'AnimatedImageFrame class' category: 'AnimatedGIF'!
AnimatedImageFrame class
	instanceVariableNames: ''!

!classDefinition: #GIFFrameCompiler category: 'AnimatedGIF'!
Object subclass: #GIFFrameCompiler
	instanceVariableNames: 'frames forms extent backgroundColor'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AnimatedGIF'!
!classDefinition: 'GIFFrameCompiler class' category: 'AnimatedGIF'!
GIFFrameCompiler class
	instanceVariableNames: ''!

!classDefinition: #LzwGifDecoder category: 'AnimatedGIF'!
Object subclass: #LzwGifDecoder
	instanceVariableNames: 'suffixTable prefixTable eoiCode clearCode bitMask codeSize minimumCodeSize maxCode nextAvailableCode numLeftoverBits codeStream codeStreamBuffer outBlock'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AnimatedGIF'!
!classDefinition: 'LzwGifDecoder class' category: 'AnimatedGIF'!
LzwGifDecoder class
	instanceVariableNames: ''!

!classDefinition: #LzwGifEncoder category: 'AnimatedGIF'!
Object subclass: #LzwGifEncoder
	instanceVariableNames: 'suffixTable prefixTable eoiCode clearCode codeSize minimumCodeSize maxCode nextAvailableCode numLeftoverBits bitBuffer codeStream codeStreamBuffer rowByteSize xPos yPos dimensions'
	classVariableNames: ''
	poolDictionaries: ''
	category: 'AnimatedGIF'!
!classDefinition: 'LzwGifEncoder class' category: 'AnimatedGIF'!
LzwGifEncoder class
	instanceVariableNames: ''!


!GIFReadWriter commentStamp: 'EG 11/22/2021 18:20:50' prior: 0!
I am GIFReadWriter.
I am a concrete ImageReadWriter.

Updated implementation of a GIF file (byte-level) decoder.

I implment a Stream-like behavior over a GIF image file, and can both read and write GIF files.

Previously in Squeak and other forks, two classes distinguished between "still" and "animated" GIFs. However, the standard specifies that any GIF can have "frames" and be animated. This reimplementation treats this as normal.

See these links for more detailed information:
 
 https://www.w3.org/Graphics/GIF/spec-gif89a.txt
 https://en.wikipedia.org/wiki/GIF
 http://www.matthewflickinger.com/lab/whatsinagif/bits_and_bytes.asp

For writing GIF files, I take a collection of AnimatedImageFrame objects and write the appropriate headers, Graphics Control Extensions, and everything else needed for writing an animated GIF.

For reading GIF files, I take a binary filestream and set my own `frames` variable to be a collection of AnimatedImageFrames, which themselves contain decoded Forms and instructions for disposal, delay, etc.

NOTE: I make use of the LzwGifDecoder and LzwGifEncoder classes in order to encode/decode individual bitmap data for each image frame of the GIF.

See `GIFReadWriter exampleAnim` for more information.  !

!GIFFrameCompiler commentStamp: 'EG 11/22/2021 18:20:26' prior: 0!
I am a utility object that takes a collection of AnimatedImageFrames and compiles an output collection of composited Forms, based on the disposal and blending rules specified by the frames. I am primarily designed to be used with AnimatedImageMorph (rather than AnimatedImageCompMorph), which takes a sequence of Forms and animates them using Morph stepping.

For examples of my use, see 
AnimatedImageMorph class >> #fromGIFReader:
AnimatedImageMorph class >> #fromFile:!

!LzwGifDecoder commentStamp: 'EG 11/22/2021 18:16:46' prior: 0!
I implement the modified Lempel-Ziv-Welch (LZW) algorithm for lossless GIF decompression. My primary purpose is to decode streams of bytes that have been encoded with this modified version of LZW as used in the GIF standard.

My instances require, at minimum, a maximum code size (via #maxCode:), a minimum code size (via #minimumCodeSize:), and of course a stream of bytes to decode (via #codeStream:). Once these are set, implementors can simply send the #decode message, which will respond with a decoded ByteArray.

Optionally, implementors can make use of the #onDecodedBit: message, which takes a Block with a single argument corresponding to a decoded bit. This Block is called each time a complete byte/bit-level value for the bitmap has been decoded.

For an example of use, see GIFReadWriter >> #readBitDataOnFrame:.

I am separated out from GIFReadWriter for clarity and better debugging.



See:
https://en.wikipedia.org/wiki/Lempel%E2%80%93Ziv%E2%80%93Welch
https://www.w3.org/Graphics/GIF/spec-gif89a.txt

!

!LzwGifEncoder commentStamp: 'EG 11/22/2021 18:16:57' prior: 0!
I implement the modified Lempel-Ziv-Welch (LZW) algorithm for lossless GIF bitmap compression. My primary purpose is to encode/compress streams of bitmap bytes as specified by the GIF standard.

My instances require at minimum:
- A size of bytes in a row of bitmap bits for the image (#rowByteSize:)
- The extent of the image being encoded (#extent:)
- An array of bits in a bitmap (as bytes) for encoding (sent with #encode:)
- A stream of Bytes on which to output the encoded bytes (#codeStream:)
- A minimum code size as specified from GIF header information (#minimimCodeSize:)

Once all of these are set, implementors simply send the #encode: message along with a
collection of bitmap values as bytes that need to be encoded. Instead of responding with a collection of encoded bytes, #encode: will write to the output stream specified by #codeStream: directly.

For an example of use, see GIFReadWriter >> #writeBitData:

NOTE: LZW compression for GIFs is complex and the #encode: method is largely taken verbatim from Kazuki Yasumatsu's 1995 Squeak implementation (as opposed to the Decoder, which was heavily refactored for readability and comprehension). Any contributions to fleshing this out in a comprehensible way are much appreciated!!

See:
https://en.wikipedia.org/wiki/Lempel%E2%80%93Ziv%E2%80%93Welch
https://www.w3.org/Graphics/GIF/spec-gif89a.txt!

!GIFReadWriter methodsFor: 'private - decoding'!
processColorsFor: anImageFrame
	"Colors can only be mapped after the GCE has been evaluated
	for a given image frame. We perform this action using either
	the local or global color table for this frame's form"
	| colorTable |
	colorTable := localColorTable ifNil: [ colorPalette ].
	
	"Use a copy so we don't mess up the global color table as we parse"
	colorTable := colorTable copyFrom: 1 to: colorTable size.
	
	transparentIndex 
		ifNotNil: [ 
			transparentIndex + 1 > colorTable size
				ifTrue: [ 
					colorTable := colorTable
										forceTo: transparentIndex + 1
										paddingWith: Color white ].
				colorTable
					at: transparentIndex + 1
					put: Color transparent ].
	anImageFrame form colors: colorTable.! !

!GIFReadWriter methodsFor: 'private - decoding'!
readApplicationExtension
	"Uses the underlying stream to read a so-called
	Application Extension to the GIF Image. These extensions
	are at the whole file -- not individual frame like a GCE --
	level. It appears the only kind widely used is the NETSCAPE
	extension for determining the number of times an animated
	GIF should loop."
	| bytesFollow appName appAuthCode caughtInfo numSubBlocks loopVal1 loopVal2 |
	"How many bytes before data begins?
	Usually 11"
	bytesFollow := self next.
	appName := (String streamContents: [ :s |
		1 to: 8 do: [ :num |
			s
				nextPut: self next asCharacter ] ]).
	appAuthCode := (String streamContents: [ :s |
		1 to: 3 do: [ :num |
			s
				nextPut: self next asCharacter ] ]).
	caughtInfo := (appName size + appAuthCode size).
	caughtInfo = bytesFollow ifFalse: [ 
		(bytesFollow = caughtInfo) timesRepeat: [ 
			self next ] ].
	numSubBlocks := self next.
	appName = 'NETSCAPE' 
		ifTrue: [ 
			self next. "Data sub-block index (always 1)"
			"If it's the NETSCAPE extension, the next
			byte will set the loopCount. This is stored in
			a 2-byte lo-hi unsigned format"
			loopVal1 := self next.
			loopVal2 := self next.
			loopCount := (loopVal2 * 256) + loopVal1.
			self next = 0 ifFalse: [ ^ self error: 'Corrupt NETSCAPE Application Block' ].
			^ self ].

	"For now we ignore Application Extensions
	that are not the NETSCAPE kind"
	[ numSubBlocks = 0 ] whileFalse: [ 
		self next: numSubBlocks.
		numSubBlocks := self next ].
	! !

!GIFReadWriter methodsFor: 'private - decoding' stamp: 'EG 11/21/2021 11:10:47'!
readBitDataOnFrame: aFrame
	"using modified Lempel-Ziv Welch algorithm."
	| initCodeSize  packedBits hasLocalColor localColorSize maxOutCodes decoder c  bytes |
	maxOutCodes := 4096.
	offset := self readWord @ self readWord.	"Image Left@Image Top"
	width := self readWord.
	height := self readWord.

	"---
	Local Color Table Flag        1 Bit
	Interlace Flag                1 Bit
	Sort Flag                     1 Bit
	Reserved                      2 Bits
	Size of Local Color Table     3 Bits
	----"
	packedBits := self next.
	interlace := (packedBits bitAnd: 64) ~= 0.
	hasLocalColor := (packedBits bitAnd: 128) ~= 0.
	localColorSize := 1 bitShift: (packedBits bitAnd: 7) + 1.
	hasLocalColor ifTrue: [ 
		localColorTable := self readColorTable: localColorSize ].
	pass := 0.
	xpos := 0.
	ypos := 0.
	rowByteSize := (width + 3) // 4 * 4.
	bytes := ByteArray new: rowByteSize * height.

	initCodeSize := self next.

	c := ColorForm 
		extent: width@height
		depth: 8. 

	decoder := LzwGifDecoder new.
	decoder 
		codeStream: stream;
		minimumCodeSize: initCodeSize;
		maxCode: maxOutCodes;
		onDecodedBit: [ :bit |
			bytes
				at: (ypos * rowByteSize + xpos + 1)
				put: bit.
			self updatePixelPosition ].
	decoder decode.
	"c bits copyFromByteArray: bytes."
	c copyFromByteArray: bytes.
	^ c! !

!GIFReadWriter methodsFor: 'private - decoding'!
readBody
	"Read the GIF blocks. Modified to return a frame."
	| block frame |
	frame := nil.
	frames := OrderedCollection new.
	[ stream atEnd ] whileFalse: [ 
		block := self next.
		
		"If we have reached the terminator byte, return."
		block = Terminator ifTrue: [ ^ frame ].
		block = ImageSeparator 
			ifTrue: [ 
				frame ifNil: [ frame := AnimatedImageFrame new ].
				frame form: (self readBitDataOnFrame: frame). "Adjusting message for testing"
				frame offset: offset. "Set from instance var, which is set in readBitData"
				
				frames add: frame.
				self processColorsFor: frame.
				self next = Terminator ifTrue: [ ^ frames last ].
				frame := nil. ]
			ifFalse: 
				[ "If it's not actual image data, perhaps
					it's an Extension of some kind (there can be several)"
					block = Extension 
						ifTrue: [ 
							frame ifNil: [ frame := AnimatedImageFrame new ].
							self readExtensionBlock: block withFrame: frame ]
						ifFalse: [ ^ self error: 'Unknown Bytes!!' ] ] 
		].
	^ frames.! !

!GIFReadWriter methodsFor: 'private - decoding'!
readColorTable: numberOfEntries 
	| array r g b |
	array := Array new: numberOfEntries.
	1 
		to: array size
		do: 
			[ :i | 
			r := self next.
			g := self next.
			b := self next.
			array 
				at: i
				put: (Color 
						r: r
						g: g
						b: b
						range: 255) ].
	^ array! !

!GIFReadWriter methodsFor: 'private - decoding'!
readCommentExtension
	| blockTerminator |
	blockTerminator := self next.
	blockTerminator > 0
		ifTrue: [ comment := self next: blockTerminator.
			blockTerminator := self next ].
	blockTerminator = 0
		ifFalse: [ ^ self error: 'Invalid Block Terminator' ]! !

!GIFReadWriter methodsFor: 'private - decoding'!
readDisposal: aPackedByte
	"Read the three-bit disposal flag from
	the packed byte in the Graphic Control Extension block.
	Disposal is three-bits with the following codes:
	 |0 0 0 [0 0 0] 0 0|
	1 => leave current frame and draw on top of it (#leaveCurrent)
	2 => Restore to background color (#restoreBackground)
	3 => Restore to state before current frame was drawn (#restorePrevState)"
	| least middle both |
	(both := (aPackedByte bitAnd: 12) = 12).
	both ifTrue: [ ^ #restorePrevState ].
	
	least := (aPackedByte bitAnd: 4) = 4.
	least ifTrue: [ ^ #leaveCurrent ].
	
	middle := (aPackedByte bitAnd: 8) = 8.
	middle ifTrue: [ ^ #restoreBackground ].
	
	^ #otherDisposal
	! !

!GIFReadWriter methodsFor: 'private - decoding'!
readExtensionBlock: aGifBlock withFrame: anImageFrame
	"Determine which type of extension block we are
	looking at. The most common is the Graphic Control Extension (GCE)
	which tells us information about the image frame, including delays
	offsets in the canvas, and how to dispose of the frame in animation"
	| extensionType packedByte delayByte1 delayByte2 |
	extensionType := self next.
	
	"255 is an Application Extension.
	 This seems to always be the NETSCAPE
	 extension, which has looping information.
	This extension does not affect individual frames,
	but rather sets the loopCount for the whole image"
	extensionType = 255 ifTrue: [ 
		^ self readApplicationExtension ].
	
	
	"249 Corresponds to the GCE"
	extensionType = 249 ifTrue: [ 
		self next = 4 ifFalse: [ ^ self "The GIF is likely corrupt in this case" ].
		"====
		Reserved                      3 Bits (Ignore)
		Disposal Method               3 Bits 
		User Input Flag               1 Bit  (Ignore)
		Transparent Color Flag        1 Bit  (Need to Implement)
		==="
		packedByte := self next.
		delayByte1 := self next.
		delayByte2 := self next.
		transparentIndex := self next.
		(packedByte bitAnd: 1) = 0 "Changed to see if other endian is the real end..."
			ifTrue: [ transparentIndex := nil ].
		anImageFrame 
			disposal: (self readDisposal: packedByte);
			"Delay time is stored as 2 bytes unsigned"
			delay: (delayByte2 * 256 + delayByte1) * 10.
		self next = 0 ifFalse: [ ^ self error: 'Corrupt GCE Block!!' ].
		^ self ].

	extensionType = 254 ifTrue: [ 
		^ self readCommentExtension ].

	"If you get to this point, we don't know the Extension Type"
	^ self error: 'Unknown GIF Extension: ',(extensionType asString).! !

!GIFReadWriter methodsFor: 'private - decoding'!
readHeader
	| is89 byte hasColorMap |
	(self hasMagicNumber: 'GIF87a' asByteArray) 
		ifTrue: [ is89 := false ]
		ifFalse: 
			[ (self hasMagicNumber: 'GIF89a' asByteArray) 
				ifTrue: [ is89 := true ]
				ifFalse: [ ^ self error: 'This does not appear to be a GIF file' ] ].
	"Width and Height for whole canvas, not
	just an invididual frame/form"
	canvasWidth := self readWord.
	canvasHeight := self readWord.
	byte := self next.
	hasColorMap := (byte bitAnd: 128) ~= 0.
	bitsPerPixel := (byte bitAnd: 7) + 1.
	backgroundColorIndex := self next.
	self next ~= 0 ifTrue: 
		[ is89 ifFalse: [ ^ self error: 'corrupt GIF file (screen descriptor)' ] ].
	hasColorMap 
		ifTrue: [ colorPalette := self readColorTable: (1 bitShift: bitsPerPixel) ]
		ifFalse: 
			[ colorPalette := nil	"Palette monochromeDefault" ]! !

!GIFReadWriter methodsFor: 'private - decoding'!
readWord
	^self next + (self next bitShift: 8)! !

!GIFReadWriter methodsFor: 'testing'!
isAnimated
	frames ifNil: [ ^ false ].
	^ frames size > 1! !

!GIFReadWriter methodsFor: 'accessing'!
backgroundColor
	backgroundColorIndex ifNotNil: [ 
		colorPalette ifNotNil: [ 
			^ colorPalette at: backgroundColorIndex + 1]].
	^ Color transparent.! !

!GIFReadWriter methodsFor: 'accessing'!
canvasHeight
	^ canvasHeight! !

!GIFReadWriter methodsFor: 'accessing'!
canvasHeight: aNumber
	canvasHeight := aNumber! !

!GIFReadWriter methodsFor: 'accessing'!
canvasWidth
	^ canvasWidth! !

!GIFReadWriter methodsFor: 'accessing'!
canvasWidth: aNumber
	canvasWidth := aNumber! !

!GIFReadWriter methodsFor: 'accessing'!
form
	"By default, answer with the first Form available in the
	ImageFrames collection. If there are not any frames, answer nil"
	frames ifNil: [ ^ nil ].
	frames ifEmpty: [ ^ nil ].
	^ frames first form.! !

!GIFReadWriter methodsFor: 'accessing'!
forms
	frames ifNil: [ ^ nil ].
	^ frames collect: [ :f | f form ].! !

!GIFReadWriter methodsFor: 'accessing'!
frames
	^ frames! !

!GIFReadWriter methodsFor: 'accessing'!
frames: aCollectionOfImageFrames
	"Set the receiver's underlying collection of
	ImageFrame objects. Used when attempting to write
	out GIF images"
	frames := aCollectionOfImageFrames! !

!GIFReadWriter methodsFor: 'accessing'!
loopCount: aNumber
	"Set looping. This must be done before any image is written!!"
	loopCount := aNumber! !

!GIFReadWriter methodsFor: 'accessing'!
nextImage
	"This method ensures older compatibility with ImageReadWriter.
	We respond with the Form corresponding to the *first image* on
	the receiver's read byte stream"
	self
		readHeader;
		readBody.
	^ self form.
	! !

!GIFReadWriter methodsFor: 'accessing' stamp: 'EG 11/22/2021 18:29:51'!
nextPutFrame: anAnimatedImageFrame
	"Given the current settings, write the bytes onto the
	output stream for the given ImageFrame and its form"
	| aForm reduced tempForm tempFrame |
	
	aForm := anAnimatedImageFrame form copy.
	"aForm unhibernate".
	aForm depth > 8 ifTrue:[
		reduced := aForm colorReduced.  "minimize depth"
		reduced depth > 8 ifTrue: [
			"Not enough color space; do it the hard way."
			reduced := reduced asFormOfDepth: 8].
	] ifFalse:[reduced := aForm].
	reduced depth < 8 ifTrue: [
		"writeBitData: expects depth of 8"
		tempForm := reduced class extent: reduced extent depth: 8.
		(reduced is: ColorForm) ifTrue:[
			tempForm
				copyBits: reduced boundingBox
				from: reduced at: 0@0
				clippingBox: reduced boundingBox
				rule: Form over
				map: nil.
			tempForm colors: reduced colors.
		] ifFalse: [reduced displayOn: tempForm].
		reduced := tempForm.
	].
	(reduced is: ColorForm) ifTrue:[
		(reduced colors includes: Color transparent) ifTrue: [
			transparentIndex := (reduced colors indexOf: Color transparent) - 1.
		]
	] ifFalse: [transparentIndex := nil].
	width := reduced width.
	height := reduced height.
	bitsPerPixel := reduced depth.
	colorPalette := reduced colormapIfNeededForDepth: 32.
	interlace := false.
	tempFrame := AnimatedImageFrame new 
		form: reduced;
		offset: anAnimatedImageFrame offset;
		delay: anAnimatedImageFrame delay;
		disposal: anAnimatedImageFrame disposal.
	self writeHeader.
	self writeFrameHeader: tempFrame.
	self writeBitData: reduced bits.! !

!GIFReadWriter methodsFor: 'accessing'!
nextPutImage: aForm
	"Given the current settings, write the bytes onto the
	output stream for the given ImageFrame and its form"
	| reduced tempForm tempFrame |
	
	aForm unhibernate.
	aForm depth > 8 ifTrue:[
		reduced := aForm colorReduced.  "minimize depth"
		reduced depth > 8 ifTrue: [
			"Not enough color space; do it the hard way."
			reduced := reduced asFormOfDepth: 8].
	] ifFalse:[reduced := aForm].
	reduced depth < 8 ifTrue: [
		"writeBitData: expects depth of 8"
		tempForm := reduced class extent: reduced extent depth: 8.
		(reduced isColorForm) ifTrue:[
			tempForm
				copyBits: reduced boundingBox
				from: reduced at: 0@0
				clippingBox: reduced boundingBox
				rule: Form over
				fillColor: nil
				map: nil.
			tempForm colors: reduced colors.
		] ifFalse: [reduced displayOn: tempForm].
		reduced := tempForm.
	].
	(reduced isColorForm) ifTrue:[
		(reduced colorsUsed includes: Color transparent) ifTrue: [
			transparentIndex := (reduced colors indexOf: Color transparent) - 1.
		]
	] ifFalse: [transparentIndex := nil].
	width := reduced width.
	height := reduced height.
	bitsPerPixel := reduced depth.
	colorPalette := reduced colormapIfNeededForDepth: 32.
	interlace := false.
	tempFrame := AnimatedImageFrame new 
		form: reduced;
		offset: reduced offset.
	self writeHeader.
	self writeFrameHeader: tempFrame.
	self writeBitData: reduced bits.! !

!GIFReadWriter methodsFor: 'accessing'!
setStream: aStream 
	"Feed it in from an existing source"
	stream := aStream! !

!GIFReadWriter methodsFor: 'accessing'!
understandsImageFormat
	^('abc' collect: [:x | stream next asCharacter]) = 'GIF'! !

!GIFReadWriter methodsFor: 'accessing'!
writeFrameHeader: anImageFrame
	"Write any Extensions and/or headers that apply
	to individual frames/subimages"
	| interlaceByte |
	anImageFrame delay notNil | transparentIndex notNil ifTrue: [ 
		self writeGCEForFrame: anImageFrame ].
	
	"Next is the image descriptor"
	self 
		nextPut: ImageSeparator;
		writeWord: (anImageFrame offset x);
		writeWord: (anImageFrame offset y);
		writeWord: (anImageFrame form extent x);
		writeWord: (anImageFrame form extent y).
	
	interlaceByte := interlace
		ifTrue: [ 64 ]
		ifFalse: [ 0 ].
	self nextPut: interlaceByte
	! !

!GIFReadWriter methodsFor: 'private - encoding'!
writeBitData: bits 
	"using modified Lempel-Ziv Welch algorithm."
	| encoder initCodeSize |
	encoder := LzwGifEncoder new
		rowByteSize: (width * 8 + 31) // 32 * 4;
		extent: width@height;
		codeStream: stream.
	initCodeSize := bitsPerPixel <= 1 
		ifTrue: [ 2 ]
		ifFalse: [ bitsPerPixel ].
	encoder minimumCodeSize: initCodeSize.
	encoder encode: bits.! !

!GIFReadWriter methodsFor: 'private - encoding'!
writeGCEForFrame: anAnimatedImageFrame
	"Writes a Graphics Control Extension onto
	the output stream for the given image frame"
	| nextDelay packedByte |
	nextDelay := anAnimatedImageFrame delay.
	anAnimatedImageFrame delay ifNil: [ nextDelay := 0 ].
	"Set the bits of the packed byte"
	"====
		Reserved                      3 Bits (Ignore)
		Disposal Method               3 Bits 
		User Input Flag               1 Bit  (Ignore)
		Transparent Color Flag        1 Bit 
		==="
	packedByte := 0.
	transparentIndex
		ifNotNil: [ packedByte := 1 ].
	packedByte := self 
		writeDisposal: (anAnimatedImageFrame disposal)
		toPackedByte: packedByte.
	
	self 
		nextPut: Extension;
		nextPutAll: #(249 4) asByteArray;
		nextPut: packedByte;
		"nextPut: (transparentIndex
				ifNil: [ 0 ]
				ifNotNil: [ 9 ]);"
		writeWord: nextDelay // 10;
		nextPut: (transparentIndex ifNil: [ 0 ]);
		nextPut: 0.! !

!GIFReadWriter methodsFor: 'private - encoding'!
writeHeader
	| byte |
	"Write the overall image file header onto the
	output stream. This includes the global information
	about the file, such as canvasWidth etc. Only do so
	if the stream is in the initial position."
	stream position = 0 ifFalse: [ ^ self ].

	self nextPutAll: 'GIF89a' asByteArray.
	self writeWord: width.	"Screen Width"
	self writeWord: height.	"Screen Height"
	byte := 128.	"has color map"
	byte := byte bitOr: (bitsPerPixel - 1 bitShift: 5).	"color resolution"
	byte := byte bitOr: bitsPerPixel - 1.	"bits per pixel"
	self nextPut: byte.
	self nextPut: 0.	"background color."
	self nextPut: 0.	"reserved / unused 'pixel aspect ratio"
	colorPalette do: 
		[ :pixelValue | 
		self
			nextPut: ((pixelValue bitShift: -16) bitAnd: 255);
			nextPut: ((pixelValue bitShift: -8) bitAnd: 255);
			nextPut: (pixelValue bitAnd: 255) ].
	loopCount notNil ifTrue: 
		[ self writeNetscapeExtension ].! !

!GIFReadWriter methodsFor: 'private - encoding'!
writeNetscapeExtension
	"Writes a GIF Application Extension corresponding
	to the NETSCAPE2.0 version, with specifies the loopCount."
	self
		nextPut: Extension;
		nextPut: 255; "Indicates Application Extension"
		nextPut: 11; "Indicates how many bytes follow, almost always 11"
		nextPutAll: ('NETSCAPE2.0' asByteArray);
		nextPut: 3;
		nextPut: 1;
		writeWord: (loopCount ifNil: [ 0 ]);
		nextPut: 0.! !

!GIFReadWriter methodsFor: 'private - encoding'!
writeWord: aWord
	self nextPut: (aWord bitAnd: 255).
	self nextPut: ((aWord bitShift: -8) bitAnd: 255).
	^aWord! !

!GIFReadWriter methodsFor: 'writing'!
writeDisposal: aSymbol toPackedByte: aByte
	"Using the GIF Graphics Control Extension
	packed byte format, respond with a modified version
	of the passed byte that includes the correct 3-bit
	disposal code corresponding to the passed in symbol"
	
	aSymbol = #restoreBackground
		ifTrue: [ 
			"This is a value of 2 in the 3-bit structure,
			so 010, then shifted two to the left (equal to 8)"
			^ aByte + (2 bitShift: 2) ].
	
	aSymbol = #leaveCurrent
		ifTrue: [ 
			"This is a value of 1 in the 3-bit structure,
			so 001, then shifted two to the left (equal to 4)"
			^ aByte + (1 bitShift: 2) ].
	
	aSymbol = #restorePrevState
		ifTrue: [ 
			"This is a value of 3 in the 3-bit structure,
			so 011, then shifted two to the left (equal to 12)"
			^ aByte + (3 bitShift: 2) ].
	^ aByte
		! !

!GIFReadWriter methodsFor: 'private'!
updatePixelPosition
	(xpos := xpos + 1) >= width ifFalse: [ ^ self ].
	xpos := 0.
	interlace ifFalse: 
		[ ypos := ypos + 1.
		^ self ].
	pass = 0 ifTrue: 
		[ (ypos := ypos + 8) >= height ifTrue: 
			[ pass := pass + 1.
			ypos := 4 ].
		^ self ].
	pass = 1 ifTrue: 
		[ (ypos := ypos + 8) >= height ifTrue: 
			[ pass := pass + 1.
			ypos := 2 ].
		^ self ].
	pass = 2 ifTrue: 
		[ (ypos := ypos + 4) >= height ifTrue: 
			[ pass := pass + 1.
			ypos := 1 ].
		^ self ].
	pass = 3 ifTrue: 
		[ ypos := ypos + 2.
		^ self ].
	^ self error: 'can''t happen'! !

!GIFReadWriter methodsFor: 'stream access' stamp: 'EG 11/22/2021 18:32:47'!
close
	"Write terminator"
	self nextPut: Terminator.
! !

!GIFReadWriter class methodsFor: 'examples' stamp: 'EG 11/22/2021 18:25:01'!
exampleAnim
	"This example writes out an animated gif of
	 a red circle"

	| writer extent center frameDelay |
	writer := GIFReadWriter onBinaryStream: (FileEntry withPathName: 'anim.gif') writeStream binary.
	writer loopCount: 20.		"Repeat 20 times"
	frameDelay := 10.		"Wait 10/100 seconds"
	extent := 42@42.
	center := extent / 2.
	Cursor writeCursor showWhile: [
		[2 to: center x - 1 by: 2 do: [:r |
			"Make a fancy anim without using Canvas - inefficient as hell"
			| frame |
			frame := AnimatedImageFrame new
				delay: frameDelay;
				form: (ColorForm extent: extent depth: 8).
			0.0 to: 359.0 do: [:theta | frame form colorAt: (center + (Point r: r degrees: theta)) rounded put: Color red].
			writer nextPutFrame: frame]
		]	ensure: [writer close]].! !

!GIFReadWriter class methodsFor: 'initialization' stamp: 'EG 11/21/2021 10:02:34'!
initialize
	"GIFReadWriter initialize"
	ImageSeparator := $, codePoint.
	Extension := $!! codePoint.
	Terminator := $; codePoint! !

!GIFReadWriter class methodsFor: 'image reading/writing'!
typicalFileExtensions
	"Answer a collection of file extensions (lowercase) which files that I can 
	read might commonly have"

	^ self allSubclasses
		detect: [ :cls | cls wantsToHandleGIFs ]
		ifFound: [ #() ]
		ifNone: [ 
			"if none of my subclasses wants , then i''ll have to do"
			#('gif') ]! !

!GIFReadWriter class methodsFor: 'image reading/writing'!
wantsToHandleGIFs
	^ true! !

!AnimatedImageMorph methodsFor: 'as yet unclassified' stamp: 'EG 11/22/2021 12:15:07'!
delay
	^ delay! !

!AnimatedImageMorph methodsFor: 'as yet unclassified' stamp: 'EG 11/22/2021 12:15:02'!
delay: inMilliseconds
	delay _ inMilliseconds! !

!AnimatedImageMorph methodsFor: 'as yet unclassified' stamp: 'EG 11/22/2021 12:16:20'!
drawOn: aCanvas
	aCanvas
		image: (forms at: currentIdx)
		at: 0@0! !

!AnimatedImageMorph methodsFor: 'as yet unclassified' stamp: 'EG 11/22/2021 12:14:46'!
forms
	^ forms! !

!AnimatedImageMorph methodsFor: 'as yet unclassified' stamp: 'EG 11/22/2021 12:14:41'!
forms: aCollection
	forms _ aCollection! !

!AnimatedImageMorph methodsFor: 'as yet unclassified' stamp: 'EG 11/22/2021 12:13:58'!
initialize
	super initialize.
	forms _ OrderedCollection new.
	currentIdx _ 1.
	delay _ 100.! !

!AnimatedImageMorph methodsFor: 'as yet unclassified' stamp: 'EG 11/22/2021 12:22:36'!
step
	((currentIdx + 1) > forms size)
		ifTrue: [ currentIdx _ 1]
		ifFalse: [ currentIdx _ currentIdx + 1].
	self redrawNeeded.! !

!AnimatedImageMorph methodsFor: 'as yet unclassified' stamp: 'EG 11/22/2021 12:15:17'!
stepTime
	^ delay! !

!AnimatedImageMorph class methodsFor: 'as yet unclassified' stamp: 'EG 11/22/2021 12:38:39'!
fromFile: aStringOrEntry
	| reader |
	reader _ GIFReadWriter onBinaryStream: aStringOrEntry asFileEntry readStream binary.
	reader
		readHeader;
		readBody.
	^ self fromGIFReader: reader! !

!AnimatedImageMorph class methodsFor: 'as yet unclassified' stamp: 'EG 11/22/2021 12:37:35'!
fromGIFReader: aReader
	| compiler |
	compiler _ GIFFrameCompiler new
		frames: aReader frames;
		backgroundColor: aReader backgroundColor;
		extent: (aReader canvasWidth)@(aReader canvasHeight);
		compile.
	^ self new
		delay: aReader frames first delay;
		forms: compiler forms;
		morphExtent: compiler extent;
		yourself! !

!AnimatedImageMorph class methodsFor: 'as yet unclassified' stamp: 'EG 11/22/2021 18:04:27'!
gifFromBinaryStream: aStream
	| reader |
	reader _ GIFReadWriter onBinaryStream: aStream.
	reader
		readHeader;
		readBody.
	^ self fromGIFReader: reader
	! !

!AnimatedImageFrame methodsFor: 'accessing'!
delay
	^ delay! !

!AnimatedImageFrame methodsFor: 'accessing'!
delay: aNumber
	delay := aNumber! !

!AnimatedImageFrame methodsFor: 'accessing'!
disposal
	^ disposal! !

!AnimatedImageFrame methodsFor: 'accessing'!
disposal: aSymbol
	"Disposal must be one of:
		#restoreBackground
		#leaveCurrent
		#restorePreviousState"
	"({ #restoreBackground.
		#leaveCurrent.
		#restorePreviousState } includes: aSymbol) ifTrue: [ 
			disposal := aSymbol ]."
	disposal := aSymbol! !

!AnimatedImageFrame methodsFor: 'accessing'!
form
	^ form! !

!AnimatedImageFrame methodsFor: 'accessing'!
form: aForm
	form := aForm! !

!AnimatedImageFrame methodsFor: 'accessing'!
offset
	^ offset! !

!AnimatedImageFrame methodsFor: 'accessing'!
offset: aPoint
	"This represents the frame form's offset in the
	parent image canvas"
	offset := aPoint! !

!AnimatedImageFrame methodsFor: 'initialization'!
initialize
	super initialize.
	offset := 0 @ 0.
	delay := self defaultDelay.
	disposal := #otherDisposal! !

!AnimatedImageFrame methodsFor: 'defaults'!
defaultDelay
	^ 66! !

!GIFFrameCompiler methodsFor: 'as yet unclassified' stamp: 'EG 11/22/2021 12:27:30'!
compile
	"For each AnimatedImageFrame, use its information and disposal
	to compile individual, full Forms for each frame (ie composites)"
	| stream currentForm currentCanvas frame |
	stream _ frames readStream.
	frame _ stream next.
	currentForm _ Form extent: self extent depth: frame form depth.
	currentCanvas _ BitBltCanvas onForm: currentForm.
	"Draw the first frame"
	currentCanvas
		image: frame form
		at: frame offset.
	self forms add: currentCanvas form.
	[ stream atEnd ] whileFalse: [
		frame _ stream next.
		currentForm _ Form extent: self extent depth: frame form depth.
		currentCanvas _ BitBltCanvas onForm: currentForm.
		(frame disposal = #leaveCurrent)
			ifTrue: [ 
				currentCanvas
					image: self forms last
					at: 0@0;
					image: frame form
					at: frame offset ]
			ifFalse: [ 
				currentCanvas
					fillRectangle: ((0@0) extent: self extent)
					color: self backgroundColor;
					image: frame form
					at: frame offset ].
			forms add: currentCanvas form ].
	
	! !

!GIFFrameCompiler methodsFor: 'as yet unclassified' stamp: 'EG 11/22/2021 11:55:30'!
extent
	^ extent! !

!GIFFrameCompiler methodsFor: 'as yet unclassified' stamp: 'EG 11/22/2021 11:55:22'!
extent: aPoint
	extent _ aPoint! !

!GIFFrameCompiler methodsFor: 'as yet unclassified' stamp: 'EG 11/22/2021 11:54:05'!
initialize
	super initialize.
	frames := OrderedCollection new.
	forms := OrderedCollection new.! !

!GIFFrameCompiler methodsFor: 'accessing' stamp: 'EG 11/22/2021 12:08:52'!
backgroundColor
	^ backgroundColor! !

!GIFFrameCompiler methodsFor: 'accessing' stamp: 'EG 11/22/2021 12:09:05'!
backgroundColor: aColor
	backgroundColor _ aColor! !

!GIFFrameCompiler methodsFor: 'accessing' stamp: 'EG 11/22/2021 11:54:26'!
forms
	"Answer the value of forms"

	^ forms! !

!GIFFrameCompiler methodsFor: 'accessing' stamp: 'EG 11/22/2021 11:54:26'!
forms: anObject
	"Set the value of forms"

	forms _ anObject! !

!GIFFrameCompiler methodsFor: 'accessing' stamp: 'EG 11/22/2021 11:54:26'!
frames
	"Answer the value of frames"

	^ frames! !

!GIFFrameCompiler methodsFor: 'accessing' stamp: 'EG 11/22/2021 11:54:26'!
frames: anObject
	"Set the value of frames"

	frames _ anObject! !

!LzwGifDecoder methodsFor: 'private'!
checkCodeSize
	"Ensure that the next available code to enter
	into the table is not equal to the bitMask.
	If it is, we increment the code size and update the
	mask value."
	nextAvailableCode := nextAvailableCode + 1.
	(nextAvailableCode bitAnd: bitMask) = 0
		ifTrue: [ 
			"GIF89a specifies a 'deferred' clearCode
			implementation, which means we keep going
			with the current table even if its full but
			a clear hasn't been found. We use the max
			code size at that point."
			nextAvailableCode >= maxCode ifTrue: [ ^ self ].
			codeSize := codeSize + 1.
			bitMask := bitMask + nextAvailableCode ].! !

!LzwGifDecoder methodsFor: 'private'!
codeStream: aReadableStream 
	"Set the stream of encoded bytes we will decode
	to be the internal codeStream. We read off the first
	byte immediately, which tells us how many subsequent bytes
	to use in our buffer for decoding"
	| chunkSize |
	codeStream := aReadableStream.
	chunkSize := codeStream next.
	codeStreamBuffer := ReadStream on: (codeStream next: chunkSize).! !

!LzwGifDecoder methodsFor: 'private' stamp: 'EG 11/21/2021 10:16:51'!
handleCode: anInteger withPreviousCode: prevInteger on: aWriteStream
	"Check for the code in the tables
	and perform the appropriate LZW action"
	| first searchIndex searchStack |
	"The code already exists in the table"
	anInteger < nextAvailableCode
		ifTrue: [ 
			anInteger < clearCode
				"If it's less than the clearCode
				then it is one of the original entries
				and we can simply use the suffix"
				ifTrue: [ 
					first := (suffixTable at: (anInteger + 1)).
					self writeBit: first on: aWriteStream ]
				"Otherwise we need to loop backwards along
				the prefix index values and take the suffix each
				time"
				ifFalse: [ 
					searchStack := OrderedCollection new.
					searchIndex := anInteger + 1.
					[ searchIndex > clearCode ] whileTrue: [ 
						searchStack add: (suffixTable at: searchIndex).
						searchIndex := (prefixTable at: searchIndex) + 1 ].
					searchStack add: (suffixTable at: searchIndex).
					first := searchStack last.
					searchStack reverseDo: [ :int |
						self writeBit: int on: aWriteStream ] ]. 
			]
		ifFalse: [ 
			"Here, the incoming code is not yet in the code tables"
			prevInteger < clearCode
				ifTrue: [ 
					first := (suffixTable at: (prevInteger + 1)).
					self
						writeBit: first on: aWriteStream;
						writeBit: first on: aWriteStream.
					 ]
				ifFalse: [ 
					searchStack := OrderedCollection new.
					searchIndex := prevInteger + 1.
					[ searchIndex > clearCode ] whileTrue: [ 
						searchStack add: (suffixTable at: searchIndex).
						searchIndex := (prefixTable at: searchIndex) + 1 ].
					searchStack add: (suffixTable at: searchIndex).
					first := searchStack last.
					searchStack reverseDo: [ :int |
						self writeBit: int on: aWriteStream ].
					self writeBit: first on: aWriteStream ]. 
			].
		"We add prevCode and the new
		suffix to a new entry in the code table, but
		only if we aren't at the max. NOTE: due to
		GIF 89a spec's 'deferred clear', if you get to
		the maxCode and haven't seen a clear, you stop
		writing to the tables but continue querying."
		nextAvailableCode >= maxCode
			ifFalse: [ 
				suffixTable at: (nextAvailableCode + 1) put: first.
				prefixTable at: (nextAvailableCode + 1) put: prevInteger ].
		self checkCodeSize.! !

!LzwGifDecoder methodsFor: 'private'!
nextCode
	| integer numBitsRead newRemainder shiftAmount byte |
	"Retrieve the next code of codeSize bits.
	Store the remaining bits etc for later computation"
	integer := 0.
	numLeftoverBits = 0
		ifTrue: [ 
			numBitsRead := 8.
			shiftAmount := 0 ]
		ifFalse: [ 
			numBitsRead := numLeftoverBits.
			shiftAmount := numLeftoverBits - 8 ].
		[ numBitsRead < codeSize ] whileTrue: [ 
			byte := self nextByte.
			byte == nil ifTrue: [ ^ eoiCode ].
			integer := integer + (byte bitShift: shiftAmount).
			shiftAmount := shiftAmount + 8.
			numBitsRead := numBitsRead + 8 ].
		(newRemainder := numBitsRead - codeSize) = 0
			ifTrue: [ byte := self nextByte ]
			ifFalse: [ byte := self peekByte ].
		byte == nil ifTrue: [ ^ eoiCode ].
		numLeftoverBits := newRemainder.
		^ integer + (byte bitShift: shiftAmount) bitAnd: bitMask.! !

!LzwGifDecoder methodsFor: 'api'!
decode
	| currentCode prevCode outStream |
	self initializeTables.
	outStream := WriteStream with: (ByteArray new).
	numLeftoverBits := 0.
	currentCode := self nextCode.
	currentCode = clearCode ifFalse: [ ^ self error: 'First code on the stream should always be the clear code!!' ].
	
	"The first real code simply gets output
	onto the stream, then we enter the loop"
	currentCode := self nextCode.
	self writeBit: currentCode on: outStream.
	prevCode := currentCode.
	currentCode := self nextCode.
	[ currentCode = eoiCode ] whileFalse: [ 
		currentCode = clearCode
			ifTrue: [ 
				self initializeTables.
				currentCode := self nextCode.
				self
					writeBit: (suffixTable at: (currentCode + 1))
					on: outStream.
				prevCode := nil ]
			ifFalse: [ self handleCode: currentCode withPreviousCode: prevCode on: outStream ].
		prevCode := currentCode.
		currentCode := self nextCode ].
	^ outStream contents.

	
	! !

!LzwGifDecoder methodsFor: 'initialization'!
initializeTables
	"The two arrays are our lookup tables.
	We do this instead of Dictionaries because
	the method is much, much faster"
	prefixTable := Array new: (maxCode).
	suffixTable := Array new: (maxCode).
	
	"The initial code size and mask settings
	also get reinitialized each time"
	codeSize := minimumCodeSize + 1.
	clearCode := (1 bitShift: minimumCodeSize).
	eoiCode := clearCode + 1.
	nextAvailableCode := clearCode + 2.
	bitMask := (1 bitShift: codeSize) - 1.
	
	"Fill the tables with the initial values"
	1 to: clearCode do: [ :n |
		prefixTable at: n put: (n - 1).
		suffixTable at: n put: (n - 1) ].
	! !

!LzwGifDecoder methodsFor: 'accessing'!
maxCode: anInteger 
	maxCode := anInteger! !

!LzwGifDecoder methodsFor: 'accessing'!
minimumCodeSize: anInteger 
	minimumCodeSize := anInteger! !

!LzwGifDecoder methodsFor: 'accessing'!
onDecodedBit: aBlock
	"This block will be executed once each time a new
	value is decoded from the stream, with the value
	as the sole argument passed to the block"
	outBlock := aBlock! !

!LzwGifDecoder methodsFor: 'writing'!
writeBit: anInteger on: aWriteStream
	"Write the incoming decoded value onto a
	writestream. If I have an outBlock set, 
	send this value also"
	aWriteStream nextPut: anInteger.
	outBlock ifNil: [ ^ self ].
	outBlock value: anInteger.! !

!LzwGifDecoder methodsFor: 'private - packing'!
nextByte
	| nextChunkSize |
	codeStreamBuffer atEnd
		ifTrue: [ 
			nextChunkSize := codeStream next.
			nextChunkSize = 0 ifTrue: [ ^ self error: 'Next chunk size was 0!!' ].
			codeStreamBuffer := (codeStream next: nextChunkSize) readStream ].
	^ codeStreamBuffer next.! !

!LzwGifDecoder methodsFor: 'private - packing'!
peekByte
	| nextChunkSize |
	codeStreamBuffer atEnd
		ifTrue: [ 
			nextChunkSize := codeStream next.
			nextChunkSize = 0 ifTrue: [ ^ self error: 'Next chunk size is 0!!' ].
			codeStreamBuffer := (codeStream next: nextChunkSize) readStream ].
	^ codeStreamBuffer peek.! !

!LzwGifEncoder methodsFor: 'accessing'!
codeStream: aByteStream
	codeStream := aByteStream.! !

!LzwGifEncoder methodsFor: 'accessing'!
dimensions: anExtentPoint
	"Set the extent (as point) of the
	image that will be encoded"
	dimensions := anExtentPoint! !

!LzwGifEncoder methodsFor: 'accessing'!
extent: anExtentPoint
	"Set the extent (as point) of the
	image that will be encoded"
	dimensions := anExtentPoint! !

!LzwGifEncoder methodsFor: 'accessing'!
minimumCodeSize: anInteger
	minimumCodeSize := anInteger! !

!LzwGifEncoder methodsFor: 'accessing'!
rowByteSize: anInteger
	rowByteSize := anInteger! !

!LzwGifEncoder methodsFor: 'initialization'!
initializeParameters
	"The initial code size and mask settings
	also get reinitialized each time"
	codeSize := minimumCodeSize + 1.
	clearCode := (1 bitShift: minimumCodeSize).
	eoiCode := clearCode + 1.
	nextAvailableCode := clearCode + 2.
	maxCode := (1 bitShift: codeSize) - 1.! !

!LzwGifEncoder methodsFor: 'private'!
checkCodeSize
	"Determine whether or not we need to increment
	the codeSize"
	(nextAvailableCode > maxCode and: [ codeSize < 12 ])
		ifTrue: [ 
			codeSize := codeSize + 1.
			maxCode := (1 bitShift: codeSize) - 1 ].! !

!LzwGifEncoder methodsFor: 'private'!
checkSettings
	"Ensure that the appropriate variables
	that are needed for proper encoding
	have been set"
	codeStream ifNil: [ ^ self error: 'You must set a codeStream (byte stream) to write onto!!' ].
	dimensions ifNil: [ ^ self error: 'You must provide the extent of the image we will encode!!' ].
	rowByteSize ifNil: [ ^ self error: 'You must provide a rowByteSize for the supplied image bits!!' ].! !

!LzwGifEncoder methodsFor: 'private'!
flushBuffer
	"Write out the current codeStreamBuffer size,
	followed by its actual contents, to the true
	output codeStream"
	codeStreamBuffer isEmpty ifTrue: [ ^ self ].
	codeStream
		nextPut: codeStreamBuffer size;
		nextPutAll: codeStreamBuffer contents.
	codeStreamBuffer := (ByteArray new: 256) writeStream.! !

!LzwGifEncoder methodsFor: 'private'!
updatePixelPosition
	"Increment the xPos. If we are at the width
	position, set xPos to 0 and increment the yPos"
	xPos := xPos + 1.
	xPos >= (dimensions x) ifFalse: [ ^ self ].
	xPos := 0.
	yPos := yPos + 1.! !

!LzwGifEncoder methodsFor: 'private - bits access'!
flushBits
	numLeftoverBits = 0 ifFalse: 
		[ self nextBytePut: bitBuffer.
		numLeftoverBits := 0 ].
	self flushBuffer! !

!LzwGifEncoder methodsFor: 'private - bits access'!
nextCodePut: anInteger
	"Attempt to put the bits on the
	output stream. If we have remaining bits,
	then we need to use bitwise operations to
	fill the next byte properly before putting
	it on the output stream"
	| numBitsWritten shiftCount newInteger |
	shiftCount := 0.
	numLeftoverBits = 0
		ifTrue: [ 
			numBitsWritten := 8.
			newInteger := anInteger ]
		ifFalse: [ 
			numBitsWritten := numLeftoverBits.
			newInteger := bitBuffer + (anInteger bitShift: 8 - numLeftoverBits) ].
	[ numBitsWritten < codeSize ] whileTrue: [ 
		self nextBytePut: ((newInteger bitShift: shiftCount) bitAnd: 255).
		shiftCount := shiftCount - 8.
		numBitsWritten := numBitsWritten + 8 ].
	(numLeftoverBits := numBitsWritten - codeSize) = 0
		ifTrue: [ self nextBytePut: (newInteger bitShift: shiftCount) ]
		ifFalse: [ bitBuffer := newInteger bitShift: shiftCount ].
	^ anInteger
	! !

!LzwGifEncoder methodsFor: 'converting'!
encode: bits
	| maxBits maxMaxCode tSize tShift fCode ent pixel index nomatch disp |
	self checkSettings.
	xPos := yPos := 0.
	codeStream nextPut: minimumCodeSize.
	bitBuffer := 0.
	numLeftoverBits := 0.
	codeStreamBuffer := WriteStream on: (ByteArray new: 256).
	self initializeParameters.
	
	"These temp vars are taken from the
	original GIFReadWriter implementation"
	maxBits := 12.
	maxMaxCode := 1 bitShift: maxBits.
	tSize := 5003.
	prefixTable := Array new: tSize.
	suffixTable := Array new: tSize.
	tShift := 0.
	fCode := tSize.
	[ fCode < 65536 ] whileTrue: [ 
		tShift := tShift + 1.
		fCode := fCode * 2 ].
	tShift := 8 - tShift.
	1 to: tSize do: [ :i |
		suffixTable at: i put: -1 ].
	
	"We immediately write the clearCode
	to the output stream"
	self writeCodeAndCheckCodeSize: clearCode.
	
	"This loop is also taken from the original
	GIFReadWriter implementation"
	ent := self readPixelFrom: bits.
	[ (pixel := self readPixelFrom: bits) == nil ] whileFalse: 
		[ fCode := (pixel bitShift: maxBits) + ent.
		index := ((pixel bitShift: tShift) bitXor: ent) + 1.
		(suffixTable at: index) = fCode 
			ifTrue: [ ent := prefixTable at: index ]
			ifFalse: 
				[ nomatch := true.
				(suffixTable at: index) >= 0 ifTrue: 
					[ disp := tSize - index + 1.
					index = 1 ifTrue: [ disp := 1 ].
					"probe"
					
					[ (index := index - disp) < 1 ifTrue: [ index := index + tSize ].
					(suffixTable at: index) = fCode ifTrue: 
						[ ent := prefixTable at: index.
						nomatch := false
						"continue whileFalse:" ].
					nomatch and: [ (suffixTable at: index) > 0 ] ] whileTrue: 
						[ "probe"
						 ] ].
				"nomatch"
				nomatch ifTrue: 
					[ self writeCodeAndCheckCodeSize: ent.
					ent := pixel.
					nextAvailableCode < maxMaxCode 
						ifTrue: 
							[ prefixTable 
								at: index
								put: nextAvailableCode.
							suffixTable 
								at: index
								put: fCode.
							nextAvailableCode := nextAvailableCode + 1 ]
						ifFalse: 
							[ self writeCodeAndCheckCodeSize: clearCode.
							1 
								to: tSize
								do: 
									[ :i | 
									suffixTable 
										at: i
										put: -1 ].
							self initializeParameters ] ] ] ].
	prefixTable := suffixTable := nil.
	self writeCodeAndCheckCodeSize: ent.
	self writeCodeAndCheckCodeSize: eoiCode.
	self flushBits.
	codeStream nextPut: 0.
				! !

!LzwGifEncoder methodsFor: 'writing'!
writeCodeAndCheckCodeSize: aCode
	self nextCodePut: aCode.
	self checkCodeSize.! !

!LzwGifEncoder methodsFor: 'private - encoding' stamp: 'EG 11/22/2021 18:35:09'!
readPixelFrom: bits
	"Using the current x and y positions and
	the specified byte size for a row, determine
	the value for the next pixel in the provided bits"
	| pixel |
	yPos >= (dimensions y) ifTrue: [ ^ nil ].
	pixel := bits byteAt: yPos * rowByteSize + xPos + 1 bigEndian: true.
	self updatePixelPosition.
	^ pixel
	! !

!LzwGifEncoder methodsFor: 'private - packing'!
nextBytePut: anInteger
	"Write a complete byte to the output byteStream.
	Be sure to reset one we reach the limit, which is
	255 for GIF files. Then write the length of the next
	byte chunks to the stream also"
	codeStreamBuffer nextPut: anInteger.
	codeStreamBuffer size >= 254
		ifTrue: [ self flushBuffer ].! !
GIFReadWriter initialize!
