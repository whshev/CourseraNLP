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

class Bgram
	attr_reader :word1, :word2

	def initialize(word1, word2)
		@word1 = word1
		@word2 = word2
	end

	def ==(other)
		self.class === other and
			other.word1 == @word1 and
			other.word2 == @word2
	end

	alias eql? ==

	def hash
		@word1.hash ^ @word2.hash
	end
end

class Tgram
	attr_reader :word1, :word2, :word3

	def initialize(word1, word2, word3)
		@word1 = word1
		@word2 = word2
		@word3 = word3
	end

	def ==(other)
		self.class === other and
			other.word1 == @word1 and
			other.word2 == @word2 and
			other.word3 == @word3
	end

	alias eql? ==

	def hash
		@word1.hash ^ @word2.hash ^ @word3.hash
	end
end

$hwordtag = {}
$h1 = {}
h2 = {}
h3 = {}
taglist = {}
$retaglist = {}
tagcount = 0
File.readlines("gene.counts.p3.out").each do |line|
	l = line.split
	if l[1] == "WORDTAG"
		wordtag = Wordtag.new l[2], l[3]
		$hwordtag[wordtag] = l[0].to_i
	elsif l[1] == "1-GRAM"
		$h1[l[2]] = l[0].to_i
		if !(taglist.key?(l[2]))
			taglist[l[2]] = tagcount
			$retaglist[tagcount] = l[2]
			tagcount += 1
		end
	elsif l[1] == "2-GRAM"
		bgram = Bgram.new l[2], l[3]
		h2[bgram] = l[0].to_i
		if !(taglist.key?(l[2]))
			taglist[l[2]] = tagcount
			$retaglist[tagcount] = l[2]
			tagcount += 1
		end
		if !(taglist.key?(l[3]))
			taglist[l[3]] = tagcount
			$retaglist[tagcount] = l[3]
			tagcount += 1
		end
	elsif l[1] == "3-GRAM"
		tgram = Tgram.new l[2], l[3], l[4]
		h3[tgram] = l[0].to_i
		if !(taglist.key?(l[2]))
			taglist[l[2]] = tagcount
			$retaglist[tagcount] = l[2]
			tagcount += 1
		end
		if !(taglist.key?(l[3]))
			taglist[l[3]] = tagcount
			$retaglist[tagcount] = l[3]
			tagcount += 1
		end
		if !(taglist.key?(l[4]))
			taglist[l[4]] = tagcount
			$retaglist[tagcount] = l[4]
			tagcount += 1
		end
	end
end

ap = Array.new(tagcount) { Array.new(tagcount) { Array.new(tagcount, -1.0)}}

0.upto(tagcount - 1) do |i|
	0.upto(tagcount - 1) do |j|
		0.upto(tagcount - 1) do |k|
			tmp2 = Bgram.new($retaglist[k], $retaglist[j])
			next if !(h2.key?(tmp2))
			c2 = h2[tmp2]
			tmp1 = Tgram.new($retaglist[k], $retaglist[j], $retaglist[i])
			h3.key?(tmp1) ? c1 = h3[tmp1] : c1 = 0.0
			ap[i][j][k] = (c1.to_f / c2.to_f)
		end
	end
end


def emiss(word, tagid)
	flag = false
	$h1.each_key do |k|
		tmp = Wordtag.new(k, word)
		if $hwordtag.key?(tmp)
			flag = true
			break
		end
	end
	if flag
		tmp = Wordtag.new $retaglist[tagid], word
	elsif word[/\d/] != nil
		tmp = Wordtag.new $retaglist[tagid], "_NUMERIC_"
	elsif (word =~ /^[A-Z]+$/) != nil
		tmp = Wordtag.new $retaglist[tagid], "_ALLCAPITALS_"
	elsif (word =~ /[A-Z]$/) != nil
		tmp = Wordtag.new $retaglist[tagid], "_ENDCAPITALS_"
	else
		tmp = Wordtag.new $retaglist[tagid], "_RARE_"
	end
	if $hwordtag.key?(tmp)
		return $hwordtag[tmp].to_f / $h1[$retaglist[tagid]].to_f
	else
		return 0.0
	end
end

words = []
STDIN.each do |line|
	word = line.chomp
	if word.length != 0
		words << word
		next
	end
	len = words.length
	f = Array.new(len+2){ Array.new(tagcount) { Array.new(tagcount, 1.0)}}
	f[0][taglist["*"]][taglist["*"]] = 0.0
	bp = Array.new(len+2){ Array.new(tagcount) { Array.new(tagcount, -1)}}
	1.upto(len) do |k|
		0.upto(tagcount - 1) do |v|
			next if v != taglist["I-GENE"] && v != taglist["O"]
			ee = emiss(words[k-1], v)
			next if ee == 0.0
			ee = Math.log(ee)
			0.upto(tagcount - 1) do |u|
				next if k < 2 && u != taglist["*"]
				next if k >= 2 && u != taglist["I-GENE"] && u != taglist["O"]
				maxnum = -1e50.to_f
				maxtag = -1
				0.upto(tagcount - 1) do |w|
					next if k < 3 && w != taglist["*"]
					next if k >= 3 && w != taglist["I-GENE"] && w != taglist["O"]
					if ap[v][u][w] > 0.0 && f[k-1][w][u] <= 0.0
						if f[k-1][w][u] + Math.log(ap[v][u][w]) + ee > maxnum
							maxnum = f[k-1][w][u] + Math.log(ap[v][u][w]) + ee
							maxtag = w
						end
					end
				end
				if maxtag != -1
					f[k][u][v] = maxnum
					bp[k][u][v] = maxtag
				end
			end
		end
	end
	maxnum = -100000000000000000.0
	maxu = -1
	maxv = -1
	y = Array.new(len + 2, 0)
	0.upto(tagcount - 1) do |v|
		next if v != taglist["I-GENE"] && v != taglist["O"]
		0.upto(tagcount - 1) do |u|
			next if u != taglist["I-GENE"] && u != taglist["O"]
			if ap[taglist["STOP"]][v][u] > 0.0 && f[len][u][v] <= 0.0
				if f[len][u][v] + Math.log(ap[taglist["STOP"]][v][u]) > maxnum
					maxnum = f[len][u][v] + Math.log(ap[taglist["STOP"]][v][u])
					maxu = u
					maxv = v
				end
			end
		end
	end
	y[len] = maxv
	y[len-1] = maxu
	(len-2).downto(1) do |i|
		y[i] = bp[i+2][y[i+1]][y[i+2]]
	end
	0.upto(len-1) do |i|
		print "#{words[i]} #{$retaglist[y[i+1]]}\n"
	end
	print "\n"

	words.clear
end
