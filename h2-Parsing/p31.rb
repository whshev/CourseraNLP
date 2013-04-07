require "rubygems"
require "json"

$dic = {}

def trverse(node)
	return if node[0] == nil
	# p node
	if node[2] == nil
		# p "haha"
		if $dic.key?(node[1])
			$dic[node[1]] += 1
		else
			$dic[node[1]] = 1
		end
		return
	end
	trverse(node[1])
	trverse(node[2])
end

def modify(node)
	return if node[0] == nil
	if node[2] == nil
		node[1] = "_RARE_" if $dic[node[1]] < 5
		# p "_RARE_"
		return
	end
	modify(node[1])
	modify(node[2])
end

fin = File.open("parse_train_vert.dat", "r")
fin.each do |line|
	parsed = JSON.parse(line)
	trverse(parsed)
end
fin.close

fin = File.open("parse_train_vert.dat", "r")
fin.each do |line|
	parsed = JSON.parse(line)
	modify(parsed)
	p parsed
end