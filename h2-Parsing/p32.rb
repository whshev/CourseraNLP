require "rubygems"
require "json"
fin = File.open("parse_train_vert.counts.out", "r")
mapcount = {}
mapnt = {}
mapbin = {}
remapnt = []

def printbp(remapnt, sent, bp, i, j, x)
	if bp[i][j][x] == ""
		sent[i-1].gsub!(/\\/, "\\\\\\\\")
		print "[\"#{remapnt[x]}\", \"#{sent[i-1]}\"]"
		return
	end
	# p bp[i][j][x]
	l = bp[i][j][x].split(" ").collect { |xx| xx.to_i }
	# return if l.length < 3
	print "[\"#{remapnt[x]}\", "
	if j == i + 1
		sent[i-1].gsub!(/\\/, "\\\\\\\\")
		sent[i].gsub!(/\\/, "\\\\\\\\")
		print "[\"#{remapnt[l[1]]}\", \"#{sent[i-1]}\"], [\"#{remapnt[l[2]]}\", \"#{sent[i]}\"]]"
		return
	end
	printbp(remapnt, sent, bp, i, l[0], l[1])
	print ", "
	printbp(remapnt, sent, bp, l[0]+1, j, l[2])
	print "]"
end

fin.each do |line|
	a = line.split(" ")
	if a[1] == "NONTERMINAL"
		mapcount[a[2]] = a[0].to_i
		if !mapnt.key?(a[2])
			remapnt << a[2]
			mapnt[a[2]] = remapnt.length - 1
		end
	elsif a[1] == "BINARYRULE"
		mapcount["#{a[2]} #{a[3]} #{a[4]}"] = a[0].to_i
		if !mapnt.key?(a[2])
			remapnt << a[2]
			mapnt[a[2]] = remapnt.length - 1
		end
		if !mapnt.key?(a[3])
			remapnt << a[3]
			mapnt[a[3]] = remapnt.length - 1
		end
		if !mapnt.key?(a[4])
			remapnt << a[4]
			mapnt[a[4]] = remapnt.length - 1
		end
		if !mapbin.key?(a[2])
			mapbin[a[2]] = []
			mapbin[a[2]] << "#{a[3]} #{a[4]}"
		else
			mapbin[a[2]] << "#{a[3]} #{a[4]}"
		end
	else
		mapcount["#{a[2]} #{a[3]}"] = a[0].to_i
		if !mapnt.key?(a[2])
			remapnt << a[2]
			mapnt[a[2]] = remapnt.length - 1
		end
	end
end

# print "step 1\n"

STDIN.each do |line|
	a = line.split(" ")
	f = Array.new(a.length+2){ Array.new(a.length+2) { Array.new(remapnt.length+2, -1.0/0.0)}}
	bp = Array.new(a.length+2){ Array.new(a.length+2) { Array.new(remapnt.length+2, "")}}
	1.upto(a.length) do |i|
		flag = true
		0.upto(remapnt.length-1) do |x|
			ss = "#{remapnt[x]} #{a[i-1]}"
			if mapcount.key?(ss)
				f[i][i][x] = Math.log(mapcount[ss].to_f / mapcount[remapnt[x]])
				flag = false
				# print "#{i} #{x} #{f[i][i][x]} #{mapcount[ss]} #{mapcount[remapnt[x]]} #{ss}\n"
			end
		end
		if flag
			0.upto(remapnt.length-1) do |x|
				ss = "#{remapnt[x]} _RARE_"
				if mapcount.key?(ss)
					f[i][i][x] = Math.log(mapcount[ss].to_f / mapcount[remapnt[x]])
					flag = false
					# print "#{i} #{x} #{f[i][i][x]} #{mapcount[ss]} #{mapcount[remapnt[x]]} #{ss}\n"
				end
			end
		end
	end
	1.upto(a.length-1) do |l|
		1.upto(a.length-l) do |i|
			j = i + l
			# next if j > a.length
			0.upto(remapnt.length-1) do |x|
				next if mapbin[remapnt[x]] == nil
				maxf = -1.0/0.0
				maxs = -1
				maxy = -1
				maxz = -1
				mapbin[remapnt[x]].each do |yz|
					t = yz.split(" ")
					y = mapnt[t[0]]
					z = mapnt[t[1]]
					qml = Math.log(mapcount["#{remapnt[x]} #{yz}"].to_f / mapcount[remapnt[x]])
					i.upto(j-1) do |s|
						next if (f[i][s][y] == -1.0/0.0 || f[s+1][j][z] == -1.0/0.0)
						sum = qml + f[i][s][y] + f[s+1][j][z]
						if sum > maxf
							maxf = sum
							maxs = s
							maxy = y
							maxz = z
						end
					end
				end
				# print "#{i} #{j} #{remapnt[x]}\n" if maxf > -1.0/0.0
				f[i][j][x] = maxf
				bp[i][j][x] = "#{maxs} #{maxy} #{maxz}"
			end
		end
	end
	# 0.upto(remapnt.length-1) do |x|
	# 	print f[1][a.length][x]
	# 	print "\n"
	# end
	# print f[1][a.length][mapnt["SBARQ"]]
	# print "\n"
	printbp(remapnt, a, bp, 1, a.length, mapnt["SBARQ"])
	print "\n"
	# exit
end

