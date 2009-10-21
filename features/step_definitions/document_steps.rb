Given 'I have the document "$filename" in my inbox' do |filename|
  @current_user.documents.create! :file => File.open(File.expand_path(RAILS_ROOT+'/spec/fixtures/'+filename))
end

Given 'I have a folder named "$name"' do |name|
  current_user.folders.find_or_create_by_name(name)
end

When "I fill out the document sharing form with:" do |table|
  fill_in_audience_form table
end

Then 'I should receive the file:' do |table|
  table.rows_hash.each do |header, value|
    case header
    when 'Filename'
      response.header['Content-Disposition'].should == %Q{attachment; filename="#{value}"}
    when 'Content Type'
      response.header['Content-Type'].should == value
    else
      raise "Unknown option: #{header}"
    end
  end
end
