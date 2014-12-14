class HomeController < ApplicationController

  def index    
    all_qu_count = Qu.count
    qu_id = 0
    while(qu_id == 0)
      qu_id = rand(all_qu_count)
    end
    @qu = Qu.find(qu_id)
    @qu.views += 1
    @qu.save
    @options = Option.find(:all, :conditions => ["qu_id = ?", @qu.id], :order => "seq")
    @ans = Ans.find(:all, :conditions => ["question_id = ?", @qu.id], :order => "created_at desc")
    @show_ans = false
    @next = @qu.id
    while(@next == @qu.id)
      @next = 0
      while(@next == 0)
        @next = rand(all_qu_count)
      end
    end
  end
  
  def ask    
  end
  
  def submit_qu
    @qu = Qu.new
    @qu.text = params[:qu]
    if(!params[:opt].nil? && !params[:opt].blank?)
      @qu.qu_type = Qu::TYPE_SINGLE
      @qu.ans = 0
      @qu.likes = 0
      @qu.views = 0
      @qu.save
      params[:opt].each do|key, value|
        opt = Option.new
        opt.qu_id = @qu.id
        opt.content = value
        opt.seq = key
        opt.save
      end
    else
      @qu.qu_type = Qu::TYPE_TEXT
      @qu.ans = 0
      @qu.likes = 0
      @qu.views = 0
      @qu.save      
    end
    render(:partial => "qu_save_res")
  end
    
  def answer
    all_qu_count = Qu.count
    @qu = Qu.find(params[:id])
    @qu.views += 1
    @qu.save
    @options = Option.find(:all, :conditions => ["qu_id = ?", @qu.id], :order => "seq")
    @ans = Ans.find(:all, :conditions => ["question_id = ?", @qu.id], :order => "created_at desc")
    @show_ans = false
    @next = @qu.id
    while(@next == @qu.id)
      @next = 0
      while(@next == 0)
        @next = rand(all_qu_count)
      end
    end
  end

  def submit_ans
    @qu = Qu.find(params[:id])
    if(!params[:ans].blank?) 
      ans = Ans.new
      ans.question_id = @qu.id
      ans.value = params[:ans]
      ans.ip = request.ip
      ans.req_details = ""
      ans.save
    end
    @options = Option.find(:all, :conditions => ["qu_id = ?", @qu.id], :order => "seq")
    @ans = Ans.find(:all, :conditions => ["question_id = ?", @qu.id], :order => "created_at desc")
    @show_ans = true
    render(:partial => "ans_list")
  end

  def search
    if(!params[:query].nil? && !params[:query].blank?) 
      qus = Qu.find(:all, :conditions => ["id = ? or text like ?", params[:query], "%#{params[:query]}%"])
      if(!qus.nil?)
        if(qus.size > 1)
          qus_ids = qus.map{|a| a.id }
          qu = 0
          while(qu == 0)
            qu = rand(qus_ids.size - 1)           
          end
          redirect_to answer_url(qus_ids[qu])
        else
          redirect_to answer_url(qus.first.id)
        end
      else
        redirect_to root_path  
      end
    else
      redirect_to root_path
    end
  end
  
end