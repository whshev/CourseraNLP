class Wordtag
	attr_reader :tag, :word

	def initialize(tag, word)
		@tag = tag
		@word = word
	end

	def ==(other)
		self.class === other and
			other.tag == @tag and
			other.word == @word
	end

	alias eql? ==

	def hash
		@tag.hash ^ @word.hash
	end
end

hwordtag = {}
h1 = {}
File.readlines("gene.counts.out").each do |line|
	l = line.split
	if l[1] == "WORDTAG"
		wordtag = Wordtag.new l[2], l[3]
		hwordtag[wordtag] = l[0].to_i
	else
		if l[1] == "1-GRAM"
			h1[l[2]] = l[0].to_i
		end
	end
end


STDIN.each do |line|
	word = line.chomp
	if word.length == 0
		print "\n"
		next
	end
	maxnum = -1.0
	tag = "0"
	flag = false
	h1.each_key do |k|
		tmp = Wordtag.new(k, word)
		if hwordtag.key?(tmp)
			flag = true
			break
		end
	end
	h1.each_pair do |k, v|
		tmp = Wordtag.new(k, word)
		if hwordtag.key?(tmp)
			if (hwordtag[tmp].to_f / v) > maxnum
				tag = k
				maxnum = hwordtag[tmp].to_f / v
			end
		else
			if flag == false
				tmp1 = Wordtag.new(k, "_RARE_")
				if (hwordtag[tmp1].to_f / v) > maxnum
					tag = k
					maxnum = hwordtag[tmp1].to_f / v
				end
			end
		end
	end
	print "#{word} #{tag}\n"
end
