class TestItemsController < ApplicationController

  def index
    add_breadcrumb 'Test Items List'
    @test_items = TestItem.all
  end

end
