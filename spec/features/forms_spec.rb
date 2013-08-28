require 'spec_helper'

describe "Forms" do
  describe "GET /" do
      it "should show the home page" do
        visit root_path
        page.should have_content "All Forms"
      end
      
      it "sets secure headers (X-Frame-Options & X-XSS-Protection)" do
        # NOTE: the app also sets X-Content-Type-Options: nosniff, but that is only set for IE browsers
        visit root_url

        expect(page.response_headers["X-Frame-Options"]).to eq "SAMEORIGIN"
        expect(page.response_headers["X-XSS-Protection"]).to eq "1; mode=block"
      end
    
    context "when there are forms in the database" do
      before {create_sample_forms}
      
      it "should list the forms on the home page and link to those forms by title and number" do
        visit root_path
        page.should have_link 'Sample Form 1 (S-1)'
        page.should have_link 'Sample Form 2 (S-2)'
      end
      
      it "should let a user navigate to a form and fill it out" do
        visit root_path
        click_link 'Sample Form 1 (S-1)'
        page.should have_content "A Text Field"
        page.should have_content "A Date Field"
        page.should have_content "A Select Field"
        fill_in 'data_text_field', with: 'America'
        click_button "Submit"
        page.should have_content "Your form has been submitted"
        page.should have_no_button "Download as PDF"
        Submission.last.data[:text_field].should == "America"
        Submission.last.data[:select_field].should be_blank
      end
      
      context "when a form has OMB data associated with it" do
        it 'displays the OMB number and expiration date at the bottom of a form' do
          visit root_path
          click_link 'Sample Form 1 (S-1)'
          expect(page).to have_content 'Form Approved OMB#4040-0001 | Expires at 2016-06-30'
        end
        
        it 'provides a link to the information collection request / OIRA conclusion on Reginfo.gov' do
          form = Form.find_by_title 'Sample Form 1'
          
          visit root_path
          click_link 'Sample Form 1 (S-1)'
          omb_link = find_link('Form Approved')

          expect(omb_link[:href]).to have_content form.icr_reference_number
        end
        
      end

      context "when a form does not have OMB data associated with it" do
        it 'does not display the omb info at the bottom of a form when the form does not have associated omb data' do
          visit root_path
          click_link 'Sample Form 2 (S-2)'
          expect(page).to have_content 'Sample Form 2 (S-2)'
          expect(page).to have_no_content 'Form Approved OMB#4040-0001 | Expires at 2016-06-30'
        end
      end
      
      context "when the form has a PDF associated with it" do
        before do
          pdf = @sample_form_1.build_pdf(url: "http://example.gov/form.pdf")
          pdf.save!
          pdf_field = pdf.pdf_fields.create!(name: 'text_field')
          pdf_field.form_field = @sample_form_1.form_fields.first
          pdf_field.save!
        end
        
        it "should allow the user to download a PDF version of their form if available" do
          visit root_path
          click_link 'Sample Form 1 (S-1)'
          fill_in 'A Text Field', with: 'America'
          click_button "Submit"
          page.should have_link "Download as PDF"
        end
      end
    end
  end
end
