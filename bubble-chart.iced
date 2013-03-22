define ["d3"], (d3) ->

	class BubbleChart
		
		# options:
		# - data: array of bubble objects
		# -- value: domain value
		# -- description: domain value description
		# - width: width of the chart
		# - height: height of the chart 
		constructor: (options) ->
			@bubbles = d3.shuffle options.data

			@width = options.width
			@height = options.height

			@maxRadius = 70

			@bubbleScale = d3.scale.sqrt().range([0, @maxRadius])
			@bubbleScale.domain [0, d3.max(@bubbles, (item) -> item.value)]

			@collisionPadding = 4
			@minCollisionRadius = 12
			@jitter = 0.5

			@textWidthFactor = 1.9

			@bubbles.forEach (bubble) =>
				bubble.radius = @bubbleScale bubble.value
				bubble.collisionRadius = Math.max @minCollisionRadius, bubble.radius

			@force = d3.layout.force()
				.gravity(0)
				.charge(0)
				.size([@width, @height])
				.on("tick", @_calculateForceFactory())

		# options:
		# - selector: chart root element selector
		plot: (options) ->
			@selector = options.selector
			@_constructCanvas()
			@_constructBackground()
			@_constructCircles()
			@_constructCaptions()			
			@force.nodes(@bubbles).start()

		# options:
		# - width: new width of the chart
		# - height: new height of the chart
		resize: (options) ->
			@width = options.width
			@height = options.height

			@force.stop()
			@_resize @canvas
			@_resize @background
			@force.size [@width, @height]
			@force.start()

		_constructCanvas: ->
			# canvas itself
			@canvas = d3
				.select(@selector)
				.selectAll("svg")
				.data([1]) # array with 1 element to simply ensure existence of 1 canvas

			# canvas construction (if does not exist, will be created)
			@canvas.enter()
				.append("svg")
				.attr("width", @width)
				.attr("height", @height)

			# in case if markup is broken, do cleanup by removing excessive canvases
			@canvas.exit().remove()

		_constructBackground: ->
			# background itself
			@background = @canvas
				.selectAll("rect")
				.data([1]) # array with 1 element to simply ensure existence of exactly 1 background

			# construction
			@background.enter()
				.append("rect")
				.attr("class", "bubble-chart-background")
				.attr("width", @width)
				.attr("height", @height)

			# removal of extra backgrounds, if any 
			@background.exit().remove()

		_constructCircles: ->
			# circles themselves
			@circles = @canvas
				.selectAll("circle")
				.data(@bubbles)

			# circles construction (if not enough, new ones will be created)
			@circles.enter()
				.append("circle")
				.attr("class", "bubble-chart-bubble")
				.attr("r", (bubble) -> bubble.radius)
				.call(@force.drag)

			# remove any excessive circles
			@circles.exit().remove()

		_constructCaptions: ->
			# hyphenation simulator
			split = (phrase) ->
				phrase
					.replace(/\S{3}[ьаеоуюыиэeyuioa](?!$)/g, (g) -> g + "-")
					.replace(/(-\S)$/, (g) -> g[1])
					.replace("- ", " ")

			# copying is needed to pass value to child function
			textWidthFactor = @textWidthFactor

			# captions themselves
			@captions = d3
				.select(@selector)
				.selectAll("div")
				.data(@bubbles)
			
			# captions construction
			@captions.enter()
				.append("span")
				.attr("class", "bubble-chart-caption")
				.style("font-size", (bubble) => Math.max(8, @bubbleScale bubble.value/2) + "px")
				.style("width", (bubble) -> "#{textWidthFactor*bubble.radius}px")
				.text((bubble) -> split bubble.description)
				.call(@force.drag)
				.each (bubble) -> 
					rect = @getBoundingClientRect()
					bubble.width = textWidthFactor*bubble.radius
					bubble.height = rect.height

			# removal of excessive captions, if any
			@captions.exit().remove()

		_resize: (element) ->
			element
				.attr("width", @width)
				.attr("height", @height)

		# pushes items towards center of chart
		_applyGravityFactory: (alpha) ->
			centerX = @width/2
			centerY = @height/2
			ax = alpha/8
			ay = alpha
			(bubble) ->
				bubble.x += (centerX - bubble.x)*ax
				bubble.y += (centerY - bubble.y)*ay

		# pushes items away from each other
		_collideFactory: ->
			(bubble) =>
				@bubbles.forEach (otherBubble) =>
					return if bubble == otherBubble
					dx = bubble.x - otherBubble.x
					dy = bubble.y - otherBubble.y
					distance = Math.sqrt(dx*dx + dy*dy)
					minDistance = bubble.collisionRadius + otherBubble.collisionRadius + @collisionPadding
					
					return if distance >= minDistance
					distance = (distance - minDistance)/distance*@jitter
					moveX = dx*distance
					moveY = dy*distance
					bubble.x -= moveX
					bubble.y -= moveY
					otherBubble.x += moveX
					otherBubble.y += moveY

		_calculateForceFactory: -> 
			(e) =>
				alpha = e.alpha*0.1
				@circles
					.each(@_applyGravityFactory(alpha))
					.each(@_collideFactory())
					.attr("transform", (bubble) -> "translate(#{bubble.x}, #{bubble.y})")
				@captions
					.style("left", (bubble) -> "#{(bubble.x - bubble.width/2)}px")
					.style("top", (bubble) -> "#{(bubble.y - bubble.height/2)}px")
