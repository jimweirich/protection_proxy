require 'rspec/given'
require 'gimme'
require 'protection_proxy'

describe ProtectionProxy do
  class User
    attr_accessor :name, :email, :membership_level

    def initialize(name, email, membership_level)
      @name = name
      @email = email
      @membership_level = membership_level
    end

    def update_attributes(attrs)
      attrs.each do |attr, value|
        send("#{attr}=", value)
      end
    end
  end

  class ProtectedUser < ProtectionProxy
    role :owner do
      writable :membership_level
    end
    role :browser do
      writable :name, :email
      writable :password
    end
  end

  Given(:user) { User.new("Jim", "jim@somewhere.com", "Beginner") }

  context "when user the owner role" do
    Given(:proxy) { ProtectedUser.find_proxy(user, :owner) }

    Then { proxy.name.should == "Jim" }

    context "when I change a writable attribute" do
      When { proxy.membership_level = "Advanced" }
      Then { proxy.membership_level.should == "Advanced" }
    end

    context "when I change a protected attribute" do
      When { proxy.name = "Joe" }
      Then { proxy.name.should == "Jim" }
    end

    context "when I use update attributes" do
      When { proxy.update_attributes(name: "Joe", membership_level: "Advanced") }
      Then { proxy.name.should == "Jim" }
      Then { proxy.membership_level.should == "Advanced" }
    end

    describe "the interaction with the original update_attributes" do
      Given(:user) { gimme(User) }
      When { proxy.update_attributes(name: "Joe", membership_level: "Advanced") }
      Then { verify(user).update_attributes(membership_level: "Advanced") }
    end
  end

  context "when user the browser role" do
    Given(:proxy) { ProtectedUser.find_proxy(user, :browser) }

    Then { proxy.name.should == "Jim" }

    context "when I change a writable attribute" do
      When { proxy.name = "Joe" }
      Then { proxy.name.should == "Joe" }
    end

    context "when I change a protected attribute" do
      When { proxy.membership_level = "SuperUser" }
      Then { proxy.membership_level.should == "Beginner" }
    end

    context "when I use update attributes" do
      When { proxy.update_attributes(name: "Joe", membership_level: "Advanced") }
      Then { proxy.name.should == "Joe" }
      Then { proxy.membership_level.should == "Beginner" }
    end

    describe "the interaction with the original update_attributes" do
      Given(:user) { gimme(User) }
      When { proxy.update_attributes(name: "Joe", membership_level: "Advanced") }
      Then { verify(user).update_attributes(name: "Joe") }
    end
  end

end
