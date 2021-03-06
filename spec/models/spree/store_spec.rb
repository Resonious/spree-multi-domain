require 'spec_helper'

describe Spree::Store do

  describe "by_domain" do 
    let!(:store)    { FactoryGirl.create(:store, slug: 'store-1', domains: "website1.com\nwww.subdomain.com") }
    let!(:store_2)  { FactoryGirl.create(:store, slug: 'store-2', domains: 'freethewhales.com') }

    it "should find stores by domain" do
      by_domain = Spree::Store.by_domain('www.subdomain.com')

      by_domain.should include(store)
      by_domain.should_not include(store_2)
    end
  end

  describe "default" do
    let!(:store)    { FactoryGirl.create(:store, slug: 'store-1') }
    let!(:store_2)  { FactoryGirl.create(:store, slug: 'store-2', default: true) }

    it "should ensure there is a default if one doesn't exist yet" do
      store.default.should be_true
    end

    it "should ensure there is only one default" do
      [store, store_2].each(&:reload)
      
      Spree::Store.default.count.should == 1
      store_2.default.should be_true
      store.default.should_not be_true
    end
  end

  describe 'parent/children', story_319: true do
    let!(:top) { create(:store, slug: 'top', parent: nil) }
    let!(:store1) { create(:store, slug: 'one', parent: top) }
    let!(:store2) { create(:store, slug: 'two', parent: top) }
    let!(:grandchild1) { create(:store, slug: 'gc1', parent: store1) }
    let!(:grandchild2) { create(:store, slug: 'gc2', parent: store1) }
    let!(:other_grandchild) { create(:store, slug: 'ogc', parent: store2) }
    let!(:ultra_grandchild) { create(:store, slug: 'ugc', parent: grandchild2) }

    describe '#all_children', all_children: true do
      let(:all_children) do
        [store1, store2, grandchild1, grandchild2, other_grandchild, ultra_grandchild]
      end

      it 'returns all children, grandchildren, etc. recursively' do
        expect(top.all_children - all_children).to eq []
      end

      context 'on a childless store' do
        it 'returns an empty array' do
          expect(ultra_grandchild.all_children).to eq []
        end
      end
    end

    describe '#up_to' do
      it 'returns all stores up the parental hirearchy including the given parent' do
        expect(ultra_grandchild.up_to(top).map(&:slug))
          .to eq [ultra_grandchild, grandchild2, store1, top].map(&:slug)
      end

      context 'when the given parent is not in the hirearchy' do
        it 'returns empty array' do
          expect(top.up_to(store1)).to eq []
        end
      end

      context 'when passed self' do
        it 'returns array with just self in it' do
          expect(top.up_to(top)).to eq [top]
        end
      end
    end
  end

  describe '#create_your_own_link', story_338: true do
    context 'when the field is nil' do
      it 'returns ""' do
        store = create :store, create_your_own_link: nil
        expect(store.create_your_own_link).to be_empty
      end
    end
  end
end
