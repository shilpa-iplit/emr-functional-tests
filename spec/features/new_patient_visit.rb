require 'spec_helper'

feature "new patient visit" do
    background do
        login('superman', 'Admin123')
    end

    scenario "registration and consultation" do
        new_patient = {:given_name => "Ram#{Time.now.to_i}", :family_name => 'Singh', :gender => 'Male', :age => {:years => 40}, :village => 'Ganiyari'}
        visit_info = {:fee => 15, :weight => 70, :height => 170, :comments => 'Billed'}
        chief_complaints = [{:name => 'Cough', :duration => {:value => 2, :unit => 'Days'}, :coded => false},
                            {:name => 'Fever', :duration => {:value => 3, :unit => 'Weeks'}, :coded => false}]
        history_and_examinations = {:chief_complaints => chief_complaints, :history_notes => "Smoking, Drinking"}
        vitals = {:pulse => 72, :diastolic => 75, :systolic => 115, :temperature => 100, :rr => 18, :spo2 => 99}

        go_to_app(:registration) do
            register_new_patient(:patient => new_patient, :visit_type => 'OPD')
            visit_page.should_be_current_page
            visit_page.save_new_patient_visit(visit_info)
        end

        go_to_app(:clinical) do
            patient_search_page.should_have_active_patient(new_patient)
            patient_search_page.view_patient(new_patient)
            patient_dashboard_page.verify_visit_vitals_info({:weight => 70, :height => 170, :bmi => 24.22, :bmi_status => 'Normal'})
            patient_dashboard_page.start_consultation
            visit_page.verify_observations({:weight => 70, :height => 170, :bmi => 24.22, :bmi_status => 'Normal'})
            visit_page.go_to_observations_page
            observations_page.fill_history_and_examinations_section(history_and_examinations)
            observations_page.fill_vitals_section(vitals)
            observations_page.save.confirm_saved
            observations_page.go_to_visit_page
            visit_page.verify_observations(vitals)
            visit_page.verify_observations(history_and_examinations)
        end
    end
end