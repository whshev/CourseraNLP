require 'set'

# en = File.open("corpus.en", "r:UTF-8")
# es = File.open("corpus.es", "r:UTF-8")
# qmap = {}
# cmap = {}
# enlines = []
# eslines = []
# begin
# 	while (enline = en.readline)
# 		enwords = ["NULL"] + enline.split(" ")
# 		enlines << enwords
# 		esline = es.readline
# 		eswords = esline.split(" ")
# 		l = enwords.size - 1
# 		m = eswords.size
# 		1.upto(m) do |i|
# 			cmap["#{i} #{l} #{m}"] = 0.0
# 			0.upto(l) do |j|
# 				qmap["#{i} #{l} #{m} #{j}"] = 1.0 / (l + 1.0)
# 				cmap["#{i} #{l} #{m} #{j}"] = 0.0
# 			end
# 		end
# 		enwords.each do |e|
# 			cmap["#{e}"] = 0.0
# 			eswords.each { |f| cmap["#{e} #{f}"] = 0.0 }
# 		end
# 		eslines << (["NULL"] + eswords)
# 	end
# rescue EOFError
# end

# print "initial done\n"

# fin = File.open("model1tmap.out", "r:UTF-8")
# tmap = {}
# fin.each do |line|
# 	a = line.split(" ")
# 	tmap["#{a[0]} #{a[1]}"] = a[2].to_f
# end

# print "tmap done\n"

# 1.upto(5) do |t|
# 	print "#{t} iteration begins\n"
# 	enlines.each_index do |k|
# 		mk = eslines[k].size - 1
# 		lk = enlines[k].size - 1
# 		1.upto(mk) do |i|
# 			sum = 0.0
# 			enlines[k].each_index do |j|
# 				sum += qmap["#{i} #{lk} #{mk} #{j}"] * tmap["#{enlines[k][j]} #{eslines[k][i]}"]
# 			end
# 			enlines[k].each_index do |j|
# 				tmp = (qmap["#{i} #{lk} #{mk} #{j}"] * tmap["#{enlines[k][j]} #{eslines[k][i]}"]) / sum
# 				cmap["#{enlines[k][j]} #{eslines[k][i]}"] += tmp
# 				cmap["#{enlines[k][j]}"] += tmp
# 				cmap["#{i} #{lk} #{mk} #{j}"] += tmp
# 				cmap["#{i} #{lk} #{mk}"] += tmp
# 			end
# 		end
# 	end
# 	print "#{t} iteration estimate begins\n"
# 	tmap.each_key do |key|
# 		k = key.split(" ")
# 		tmap[key] = cmap["#{k[0]} #{k[1]}"] / cmap["#{k[0]}"]
# 	end
# 	qmap.each_key do |key|
# 		k = key.split(" ")
# 		qmap[key] = cmap["#{k[0]} #{k[1]} #{k[2]} #{k[3]}"] / cmap["#{k[0]} #{k[1]} #{k[2]}"]
# 	end
# 	print "#{t} iteration clear begins\n"
# 	cmap.each_key { |key| cmap[key] = 0.0 }
# end

# print "train end\n"

# out1 = File.open("model2tmap.out", "w:UTF-8")
# tmap.each_pair do |key, value|
# 	out1.print "#{key} #{value}\n"
# end

# print "tmap output\n"

# out3 = File.open("model2qmap.out", "w:UTF-8")
# qmap.each_pair do |key, value|
# 	out3.print "#{key} #{value}\n"
# end

# print "qmap output\n"

tmapin = File.open("model2tmap.out", "r:UTF-8")
tmap = {}
tmapin.each do |line|
	a = line.split(" ")
	tmap["#{a[0]} #{a[1]}"] = a[2].to_f
end

print "read tmap end\n"

qmapin = File.open("model2qmap.out", "r:UTF-8")
qmap = {}
qmapin.each do |line|
	a = line.split(" ")
	qmap["#{a[0]} #{a[1]} #{a[2]} #{a[3]}"] = a[4].to_f
end

print "read qmap end\n"

deven = File.open("test.en", "r:UTF-8")
deves = File.open("test.es", "r:UTF-8")
out2 = File.open("alignment_test.p2.out", "w:UTF-8")

begin
	lino = 0
	while (enline = deven.readline)
		lino += 1
		enwords = ["NULL"] + enline.split(" ")
		esline = deves.readline
		eswords = ["NULL"] + esline.split(" ")
		l = enwords.size - 1
		m = eswords.size - 1
		1.upto(m) do |i|
			maxnum = -1.0
			maxarg = 0
			0.upto(l) do |j|
				if qmap["#{i} #{l} #{m} #{j}"] * tmap["#{enwords[j]} #{eswords[i]}"] > maxnum
					maxnum = qmap["#{i} #{l} #{m} #{j}"] * tmap["#{enwords[j]} #{eswords[i]}"]
					maxarg = j
				end
			end
			out2.print "#{lino} #{maxarg} #{i}\n"
		end
	end
rescue EOFError
end