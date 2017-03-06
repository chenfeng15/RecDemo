class FilePathController < ApplicationController

  require "mysql"
  dbh = Mysql.real_connect("localhost","root","1234","test")
  if dbh
    puts "数据库已连接"
  else
    puts "连接失败"
  end
  dbh.query('set NAMES utf8mb4')
  dbh.query('set character set utf8mb4')
  dbh.query('set character_set_connection=utf8mb4;')

#判断文件类型(后缀)的函数
  def filetype(f1,f2)
    f1_split=f1.split(".")
    f2_split=f2.split(".")
    if f1_split[-1] ==	f2_split[-1]
      return 1
    else
      return 0
    end
  end

#代码审查者推荐的算法
  def typefinder(list1)
    # 输入是以列表的信息进行的，最后得到了一个列表文件
    new_file_list=list1

    new_file_list.each do |i|
      puts i
    end
    result=$db1.query("select pr_id from test_item")
    #存放pr_id列表
    pull_list=[]
    result.each do |i|
      begin
        user1=i['pr_id']
        j=user1.to_i
        #这个判断不一定需要，但也可以是其他参数
        if 11<=j && j<=60
          pull_list << i['pr_id']
        end
      rescue Exception
        puts "..."
      end
    end
    #得分列表
    score_list = []
    #推荐者得分列表
    reviewer = {}
    #将测试的pull request和训练集进行比较。得出代码审查者的分数。
    pull_list.each do |i|
      score = 0
      old_file_list = []
      result=$db1.query("select * from test_item where pr_id=#{i}")
      result.each do |j|
        old_file_list << j['pr_route']
      end
      old_file_list.uniq!
      new_file_list.each do |new_file|
        old_file_list.each do |old_file|
          score = score + filetype(new_file,old_file)
        end
      end
      if score != 0
        score_list << score
        result=$db1.query("select distinct(user_login) from test_item where pr_id=#{i}")
        result.each do |i_id|
          user_login1 = i_id['user_login']
          reviewer[user_login1] = 0.0 if !reviewer[user_login1]
          reviewer[user_login1] += score
        end
      end
    end
    #对代码审查者根据分数进行排序reviewer1=reviewer.sort_by{|k,v|v}.reverse/如果是一起存放五组参数，那么无需对审查者预先排序
    reviewer1=reviewer.to_a
    return reviewer1
  end


#新输入的pr
  def input_file_name(pr_id,test_time)
    result=$db1.query("select pr_id,creat_at from new_item")
    pull_list=[]
    result.each do |i|
      #这个判断可能有点多余，但不知道怎么删
      if i['pr_id']>=pr_id
        date1=i['creat_at']
        j=(date1.split("-")[0]+date1.split("-")[1]).to_i
        #选出测试集，存放在pull_list列表中
        if test_time>=j
          pull_list << i['pr_id']
        end
      end
    end
    #输出测试集的数量/仅测试时使用，可删
    puts pull_list.size
    #对测试的pull request进行测试
    pull_list.each do |i|
      file_list=[]
      user_list=[]
      result=$db1.query("select * from new_item where pr_id=#{i}")
      result.each do |j|
        file_list << j['pr_route']
      end
      file_list=file_list.uniq
      predict_result = typefinder(file_list)
      predict_user_list=[]
      predict_result.each do |j|
        predict_user_list << j[0]
      end
      result=$db1.query("select * from new_item where pr_id=#{i}")
      result.each do |j|
        user_list << j['user_login']
      end

      #将所得比分结果存入数据库
      typeSimilarity=$db1.prepare("insert ignore into test_demo(user_login,pr_id,filetype) values(?,?,?)")
      puts predict_result

      typeSimilarity.execute(predict_result[0][0],i.to_s,predict_result[0][1].to_s)
      typeSimilarity.execute(predict_result[1][0],i.to_s,predict_result[1][1].to_s)
      typeSimilarity.execute(predict_result[2][0],i.to_s,predict_result[2][1].to_s)
      typeSimilarity.execute(predict_result[3][0],i.to_s,predict_result[3][1].to_s)
      typeSimilarity.execute(predict_result[4][0],i.to_s,predict_result[4][1].to_s)
    end
  end
#此处可更换为其他参数输入
  input_file_name(5,201509)

  def index
    # 我要输出的数据
    @results = ["predict_result"]
  end
end
