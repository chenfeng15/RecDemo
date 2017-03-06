class SynthesisController < ApplicationController

  require 'mysql2'

  db= Mysql2::Client.new(host:'127.0.0.1',username:"root",password:"1234",database:'test',encoding:'utf8')
  resultSet=db.query('select * from user_rec')

  def fun(resultSet)
    hashArray=resultSet.map{|hashTable|hashTable}
    theSumOfTasknum=0.0
    theSumOfPrnum=0.0
    theSumOfFiletype=0.0
    theSumOfFilepath=0.0
    theSumOfPrcomment=0.0
    theSumOfP1=0.0
    theSumOfP2=0.0
    hashArray.each do |hashTable|
      theSumOfTasknum+=hashTable['tasknum']
      theSumOfPrnum+=hashTable['prnum']
      theSumOfFiletype+=hashTable['filetype']
      theSumOfFilepath+=hashTable['filepath']
      theSumOfPrcomment+=hashTable['prcomment']
    end
    #ruby lambda,
    hashArray.each do |hashTable|
      #反向计算权重第1步
      algorithm1=->val1,val2{(val2-val1)/val2}
      if hashTable['tasknum']<1
        hashTable['tasknum']=rand
      else
        hashTable['tasknum']=algorithm1.(hashTable['tasknum'],theSumOfTasknum)
      end
      if hashTable['prnum']<1
        hashTable['prnum']=rand
      else
        hashTable['prnum']=algorithm1.(hashTable['prnum'],theSumOfPrnum)
      end
      #正向计算权重
      algorithm2=->val1,val2{(val1/val2)}
      if hashTable['filetype']!=0
        hashTable['filetype']=algorithm2.(hashTable['filetype'],theSumOfFiletype)
      else
        hashTable['filetype']=rand
      end
      if hashTable['filepath']!=0
        hashTable['filepath']=algorithm2.(hashTable['filepath'],theSumOfFiletype)
      else
        hashTable['filepath']=rand
      end
      #评论单独计算，如果>=1，认定审查过了，得1分；如果为0，不得分；
      if hashTable['prcomment']>=1
        hashTable['prcomment']=0.2
      else
        hashTable['prcomment']=0
      end
    end
    hashArray.each do |hashTable|
      #反向计算权重第2步，结果相当于公式(1-val1/val2)/Σ（val1/val2）
      theSumOfP1+=hashTable['tasknum']
      theSumOfP2+=hashTable['prnum']
    end
    hashArray.each do |hashTable|
      algorithm3=->val1,val2{val1/val2}
      hashTable['tasknum']=algorithm3.(hashTable['tasknum'],theSumOfP1)
      hashTable['prnum']=algorithm3.(hashTable['prnum'],theSumOfP2)
    end

    hashArray.map{|hashTable|[hashTable['user_login'],hashTable['pr_id'],hashTable.values[3..-1].reduce(:+)]}.sort_by(&:last).reverse
  end
#resultSet=[ {'user_id'=>66,'pr_id'=>123,'tasknum'=>11,'user_login'=>'User3','prnum'=>5,'filetype'=>30,'filepath'=>44,'prcomment'=>1},
#  {'user_login'=>'User4','user_id'=>69,'pr_id'=>123,'tasknum'=>29,'prnum'=>3,'filetype'=>26,'filepath'=>21,'prcomment'=>1},
#  {'user_login'=>'User1','user_id'=>74,'pr_id'=>123,'tasknum'=>78,'prnum'=>10,'filetype'=>29,'filepath'=>26,'prcomment'=>1},
#  {'user_login'=>'User2','user_id'=>75,'pr_id'=>123,'tasknum'=>56,'prnum'=>7,'filetype'=>50,'filepath'=>23,'prcomment'=>1},
#  {'user_login'=>'User5','user_id'=>76,'pr_id'=>123,'tasknum'=>46,'prnum'=>22,'filetype'=>41,'filepath'=>24,'prcomment'=>1},
#  {'user_login'=>'User6','user_id'=>77,'pr_id'=>123,'tasknum'=>53,'prnum'=>25,'filetype'=>66,'filepath'=>65,'prcomment'=>1},
#  {'user_login'=>'User6','user_id'=>78,'pr_id'=>123,'tasknum'=>26,'prnum'=>33,'filetype'=>42,'filepath'=>42,'prcomment'=>1},
#  {'user_login'=>'User6','user_id'=>79,'pr_id'=>123,'tasknum'=>23,'prnum'=>11,'filetype'=>35,'filepath'=>35,'prcomment'=>1},
#  {'user_login'=>'User6','user_id'=>80,'pr_id'=>123,'tasknum'=>39,'prnum'=>8,'filetype'=>77,'filepath'=>67,'prcomment'=>1},
#  {'user_login'=>'User6','user_id'=>81,'pr_id'=>123,'tasknum'=>30,'prnum'=>4,'filetype'=>44,'filepath'=>15,'prcomment'=>1}]
  puts fun(resultSet).inspect
end
