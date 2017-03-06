class FileTypeController < ApplicationController
	
	#!/usr/bin/ruby
# _*_coding:utf-8 _*_
require 'mysql2'
#连接数据库
$db1 = Mysql2::Client.new(host:'127.0.0.1',username:"root",password:"1234",database:'test',encoding:'utf8')
$db1.query('set NAMES utf8mb4')
$db1.query('set character set utf8mb4')
$db1.query('set character_set_connection=utf8mb4;')
#起始时间，2014年1月
$begin_time=201401
#截止时间 2015年8月
$end_time=201508
#最长公共前缀算法实现,即从前往后
def pathLCP(f1,f2)
	#通过分割函数split执行路径分割
	file_length1=f1.split("/").size
	file_length2=f2.split("/").size
	f1_split=f1.split("/")
	f2_split=f2.split("/")
	f1_list=[]
	f2_list=[]
	file_length1.times do |i|
		t=""
		(file_length1-i).times do |j|
			if j==0
				t=f1_split[j]
			else
				t=t+" "+f1_split[j]
			end
		end
		f1_list << t
	end
	file_length2.times do |i|
		t=" "
		(file_length2-i).times do |j|
			if j==0
				t=f2_split[j]
			else
				t=t+" "+f2_split[j]
			end
		end
		f2_list << t
	end
	in_list=[0]
	f1_list.each do |i|
		if f2_list.include?(i)
			in_list << i.split(" ").size
		end
	end
	return in_list.max
end
#最长公共后缀，从后往前
def pathLCS(f1,f2)
	file_length1=f1.split("/").size
	file_length2=f2.split("/").size
	f1_split=f1.split("/")
	f2_split=f2.split("/")
	f1_split.reverse!
	f2_split.reverse!
	f1_list=[]
	f2_list=[]
	file_length1.times do |i|
		t=""
		(file_length1-i).times do |j|
			if j==0 
				t=f1_split[j]
			else
				t=t+" "+f1_split[j]
			end
		end
		f1_list << t
	end
	file_length2.times do |i|
		t=""
		(file_length2-i).times do |j|
			if j==0
				t=f2_split[j]
			else
				t=t+" "+f2_split[j]
			end
		end
		f2_list << t
	end
	in_list=[0]
	f1_list.each do |i|
		if f2_list.include?(i)
			in_list << i.split(" ").size
		end
	end
	return  in_list.max
end

#最长公共路径，计算中间的公共模块
def pathLCSubstr(f1,f2)
	file_length1=f1.split("/").size
	file_length2=f2.split("/").size
	f1_split=f1.split("/")
	f2_split=f2.split("/")
	f1_list=[]
	f2_list=[]
	file_length1.times do |i|
		(file_length1-i).times do |j|
			k=j
			t=""
			(i+1).times do |h|
				if k==j
					t=f1_split[k]
				else
					t=t+" "+f1_split[k]
				end
				k+=1
			end
			t=t+" "+(i+1).to_s
			f1_list << t
		end
	end
	file_length2.times do |i|
		(file_length2-i).times do |j|
			k=j
			t=""
			(i+1).times do |h|
				if k==j
					t=f2_split[k]
				else
					t=t+" "+f2_split[k]
				end
				k+=1
			end
			t=t+" "+(i+1).to_s
			f2_list << t
		end
	end
	in_list=[]
	f1_list.each do |i|
		if f2_list.include?(i)
			in_list << i
		end
	end
	number_list=[0]
	in_list.each do |i|
		number_list << (i.split(" ")[i.split(" ").size-1]).to_i
	end
	return number_list.max
end
#最长公共相对序列，计算中间的相似模块
def pathLCSubseq(f1,f2)
	list1 = f1.split("/")
	list2 = []
	f1_list=[]
	f2_list=[]
	(1..list1.size).each do |i|
		iter = list1.combination(i).map(&:sort)
		list2 << iter
	end
	list2.each do |i|
		i.each do |j|
			f1_list << j
		end
	end
	# puts f1_list
	list1 = f2.split("/")
	list2 = []
	(1..list1.size).each do |i|
		iter = list1.combination(i).map(&:sort)
		list2 << iter
	end
	list2.each do |i|
		i.each do |j|
			f2_list << j
		end
	end
	# puts f2_list
	in_list=[0]
	f1_list.each do |i|
		if f2_list.include?(i)
			in_list << i.size
		end
	end
	return in_list.max
end

# 计算f1文件和f2文件的相似度
def filePathSimilarity(f1,f2)
	##调用四个算法，进行相似度计算
	a=pathLCP(f1,f2)
	b=pathLCS(f1,f2)
	c=pathLCSubseq(f1,f2)
	d=pathLCSubstr(f1,f2)
	##返回相关度分数
	return a+b+c+d
end

#代码审查者推荐的算法
def PathFinder(list1)
	### 输入是以列表的信息进行的，最后得到了一个列表文件
	new_file_list=list1
	new_file_list.each do |i|
		puts i
	end
	result=$db1.query("select pr_id from test_item")
	pull_list=[]
	result.each do |i|
		begin
			user1=i['pr_id']
			j=user1.to_i
			if 11<=j && j<=60
				pull_list << i['pr_id']
			end
		rescue Exception
			puts "..."
		end
	end
	# puts pull_list.size
	score_list=[]
	reviewer={}
	#将测试的pull request和训练集进行比较。得出代码审查者的分数。
	pull_list.each do |i|
		score=0
		old_file_list=[]
		result=$db1.query("select * from test_item where pr_id=#{i}")
		result.each do |j|
			old_file_list << j['pr_route']
		end
		old_file_list.uniq!
		new_file_list.each do |new_file|
			old_file_list.each do |old_file|
				score=score+filePathSimilarity(new_file,old_file)
			end
		end
		if score!=0
			score=score
			score_list << score
			result=$db1.query("select distinct(user_login) from test_item where pr_id=#{i}")
			result.each do |i_id|
				user_login1=i_id['user_login']
				reviewer[user_login1] = 0.0 if !reviewer[user_login1]
				reviewer[user_login1] += score
			end
		end
	end
	#对代码审查者根据分数进行排序
	reviewer1=reviewer.sort_by{|k,v|v}.reverse
	return reviewer1
end

#输入测试集的相关参数
def input_file_name(pr_id,test_time)
	result=$db1.query("select pr_id,creat_at from new_item")
	pull_list=[]
	result.each do |i|
		#
		if i['pr_id']>=pr_id
			date1=i['creat_at']
			j=(date1.split("-")[0]+date1.split("-")[1]).to_i
			#选出测试集，存放在pull_list列表中
			if test_time>=j
				pull_list << i['pr_id']
			end
		end
	end
	#输出测试集的数量
	puts pull_list.size
	#对每个测试的pull request进行测试
	pull_list.each do |i|
		file_list=[]
		user_list=[]

		result=$db1.query("select * from new_item where pr_id =#{i}")
		result.each do |j|
			file_list << j['pr_route']
		end
		file_list=file_list.uniq
		predict_result=PathFinder(file_list)
		predict_user_list=[]
		predict_result[0...5].each do |j|
			predict_user_list << j[0]
		end
		result=$db1.query("select * from new_item where pr_id =#{i}")
		result.each do |j|
			user_list << j['user_login']
		end
		#将所得比分结果存入数据库
		typeSimilarity=$db1.prepare("insert ignore into test_demo(user_login,pr_id,type) values(?,?,?)")
		puts predict_result
		typeSimilarity.execute(predict_result[0][0],i.to_s,predict_result[0][1].to_s)
		typeSimilarity.execute(predict_result[1][0],i.to_s,predict_result[1][1].to_s)
		typeSimilarity.execute(predict_result[2][0],i.to_s,predict_result[2][1].to_s)
		typeSimilarity.execute(predict_result[3][0],i.to_s,predict_result[3][1].to_s)
		typeSimilarity.execute(predict_result[4][0],i.to_s,predict_result[4][1].to_s)
	end
end
input_file_name(5,201509)

  def index
	@results = ["predict_result"]
  end
end
