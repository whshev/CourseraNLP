require 'set'

en = File.open("corpus.en", "r:UTF-8")
es = File.open("corpus.es", "r:UTF-8")
wordmap = {}
enlines = []
eslines = []
esset = Set[]
begin
	while (enline = en.readline)
		enwords = enline.split(" ")
		enlines << enwords
		esline = es.readline
		eswords = esline.split(" ")
		eslines << eswords
		enwords.each do |e|
			eswords.each do |f|
				esset << f
				if wordmap.key?(e)
					wordmap[e] << f
				else
					s = Set.new([f])
					wordmap[e] = s
				end
			end
		end
	end
rescue EOFError
end

print "wordmap done\n"

tmap = {}
cmap = {}
ce = {}
wordmap.each_pair do |e, s|
	s.each do |f|
		tmap["#{e} #{f}"] = 1.0 / s.size
		cmap["#{e} #{f}"] = 0.0
	end
	ce[e] = 0.0
end
esset.each do |f|
	tmap["NULL #{f}"] = 1.0 / esset.size
	cmap["NULL #{f}"] = 0.0
end
ce["NULL"] = 0.0

print "initial done\n"

1.upto(5) do |t|
	print "#{t} iteration begins\n"
	enlines.each_index do |k|
		eslines[k].each do |f|
			sum = 0.0
			sum += tmap["NULL #{f}"]
			enlines[k].each do |e|
				sum += tmap["#{e} #{f}"]
			end
			cmap["NULL #{f}"] += tmap["NULL #{f}"] / sum
			ce["NULL"] += tmap["NULL #{f}"] / sum
			enlines[k].each do |e|
				cmap["#{e} #{f}"] += tmap["#{e} #{f}"] / sum
				ce["#{e}"] += tmap["#{e} #{f}"] / sum
			end
		end
	end
	wordmap.each_pair do |e, s|
		s.each { |f| tmap["#{e} #{f}"] = cmap["#{e} #{f}"] / ce["#{e}"] }
	end
	esset.each { |f| tmap["NULL #{f}"] = cmap["NULL #{f}"] / ce["NULL"] }
	cmap.each_key { |key| cmap[key] = 0.0 }
	ce.each_key { |key| ce[key] = 0.0 }
end

# out1 = File.open("model1tmap.out", "w:UTF-8")
# tmap.each_pair do |key, value|
# 	out1.print "#{key} #{value}\n"
# end

# fin = File.open("model1tmap.out", "r:UTF-8")
# tmap = {}
# fin.each do |line|
# 	a = line.split(" ")
# 	tmap["#{a[0]} #{a[1]}"] = a[2].to_f
# end

print "end input\n"

deven = File.open("test.en", "r:UTF-8")
deves = File.open("test.es", "r:UTF-8")
out2 = File.open("alignment_test.p1.out", "w:UTF-8")
begin
	lino = 0
	while (enline = deven.readline)
		lino += 1
		enwords = enline.split(" ")
		# enlines << enwords
		esline = deves.readline
		eswords = esline.split(" ")
		# eslines << eswords
		findex = 0
		eswords.each do |f|
			findex += 1
			maxnum = (tmap.key?("NULL #{f}") ? tmap["NULL #{f}"] : 0.0)
			maxarg = 0
			enwords.each_index do |j|
				if tmap.key?("#{enwords[j]} #{f}")
					if tmap["#{enwords[j]} #{f}"] > maxnum
						maxnum = tmap["#{enwords[j]} #{f}"]
						maxarg = j + 1
					end
				end
			end
			out2.print "#{lino} #{maxarg} #{findex}\n"
		end
	end
rescue EOFError
end