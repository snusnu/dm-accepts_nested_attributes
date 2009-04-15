# -----------------------------------------------
# support for nice html output in rspec tmbundle
# -----------------------------------------------

module RSpecTmBundleHelpers
  
  class TextmateRspecLogger < DataMapper::Logger
    def prep_msg(message, level)
      "#{super}<br />"
    end
  end
  
  def with_dm_logger(level = :debug)
    DataMapper.logger.level = level
    yield
  ensure
    DataMapper.logger.level = :off
  end
  
  def print_call_stack(from = 2, to = nil, html = true)  
    (from..(to ? to : caller.length)).each do |idx| 
      p "[#{idx}]: #{caller[idx]}#{html ? '<br />' : ''}"
    end
  end
  
  def puth(html = nil)
    print "#{h(html)}<br />"
  end
  
  ESCAPE_TABLE = { '&'=>'&amp;', '<'=>'&lt;', '>'=>'&gt;', '"'=>'&quot;', "'"=>'&#039;', }
  def h(value)
    value.to_s.gsub(/[&<>"]/) {|s| ESCAPE_TABLE[s] }
  end
  
end
