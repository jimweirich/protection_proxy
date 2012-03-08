require 'rspec/given'
require 'protection_proxy'

describe ProtectionProxy do
  class User
    attr_accessor :name, :email, :membership_level

    def initialize(name, email, membership_level)
      @name = name
      @email = email
      @membership_level = membership_level
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
  end

end
