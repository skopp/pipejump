require 'spec/spec_helper'
describe Pipejump::Deal do

  before do 
    @session = PipejumpSpec.session
    @client = @session.clients.create(:name => 'Client1')
  end
  
  after do
    @client.destroy
  end
  
  describe '#create' do
    
    it "should create deal with valid params" do
      @deal = @session.deals.create(:name => 'New deal', :client_id => @client.id)
      @deal.attributes.keys.sort.should == ["client", "client_id", "deal_tags", "hot", "id", "name", "scope", "stage_name"] 
      (@deal.attributes.keys - ['client']).each do |attribute|
        @deal.send(attribute).should == @deal.attributes[attribute]
      end
      @deal.client.class.should == Pipejump::Client
      @deal.destroy
    end
    
    it "should return errors with invalid params" do
      @deal = @session.deals.create({})
      @deal.id.should == nil
      @deal.errors['deal'].collect{ |e| e['error']['field'] }.sort.should == ['client', 'name']
    end
    
  end
  
  describe '.find' do

    it "should find deal" do
      @deal = @session.deals.create(:name => 'New deal', :client_id => @client.id)
      @found = @session.deals.find(@deal.id)
      @found.name == @deal.name
      @deal.destroy
    end
      
    it "should raise error if not found" do
      lambda {
        @session.deals.find(-1)
      }.should raise_error(Pipejump::ResourceNotFound)
    end
  end
  
  describe '#update' do
   
    before do
      @deal = @session.deals.create(:name => 'New deal', :client_id => @client.id)
    end
    
    after do 
      @deal.destroy
    end 
    
    it "should update deal with valid params" do
      @deal.name = 'Updated deal'
      @deal.save
      @deal.save.should == true
      @found = @session.deals.find(@deal.id)
      @found.name.should == 'Updated deal'
    end
    
    it "should return errors with invalid params" do
      @deal.name = ''
      @deal.save.should == false      
      @deal.errors['deal'].collect{ |e| e['error']['field'] }.sort.should == ['name']
    end
    
  end
  
  describe '#contacts' do
    
    before do 
      @deal = @session.deals.create(:name => 'New deal', :client_id => @client.id)
      @contact = @session.contacts.create(:name => 'Tom', :client_id => @client.id)
      @contact2 = @session.contacts.create(:name => 'Mike', :client_id => @client.id)
      @deal.contacts.update(@contact.id).should == true
    end
    
    after do
      @contact.destroy
      @contact2.destroy
    end
    
    it "should return a collection of contacts" do
      contacts = @deal.contacts
      contacts.class.should == Pipejump::Collection
      contacts.respond_to?(:update).should == true
      contacts.size.should == 1
    end
    
    describe '#update' do
      
      it "should update a collection of contacts and be smart about it" do
        @deal.contacts.update([@contact.id, @contact2.id])
        @deal.contacts.size.should == 2
        @deal.contacts.update([@contact])
        @deal.contacts.size.should == 1
        @deal.contacts.update([@contact.id, @contact2])
        @deal.contacts.size.should == 2
        @deal.contacts.update([@contact2.id])
        @deal.contacts.size.should == 1
        @deal.contacts.update([@contact.id, @contact2.id].join(','))
        @deal.contacts.size.should == 2
      end
      
    end
    
  end
  
end