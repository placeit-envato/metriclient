class Error < ActiveRecord::Base
  def to_pretty_hash
    return {
      error: self.error,
      line: self.line,
      url: self.url,
      created_at: self.created_at,
      frame: self.frame,
      site_id: self.site_id,
      user_agent: self.user_agent,
      scoped_class_name: self.scoped_class_name,
      meta: Psych.load(self.meta)
    }
  end
end
