import { BrowserRouter as Router, Routes, Route, Navigate } from 'react-router-dom';
import { AuthProvider } from './context/AuthContext';
import { CheckupProvider } from './context/CheckupContext';

// Pages
import Welcome from './pages/Welcome';
import RoleSelection from './pages/RoleSelection';
import PatientLogin from './pages/patient/Login';
import PatientSignup from './pages/patient/Signup';
import ForgotPassword from './pages/patient/ForgotPassword';
import RecoverPatientId from './pages/patient/RecoverPatientId';
import PatientDashboard from './pages/patient/Dashboard';
import DoctorLogin from './pages/doctor/Login';
import DoctorForgotPassword from './pages/doctor/ForgotPassword';
import DoctorDashboard from './pages/doctor/Dashboard';
import TempCheck from './pages/patient/Checkup/TempCheck';
import OxygenCheck from './pages/patient/Checkup/OxygenCheck';
import LungFunction from './pages/patient/Checkup/LungFunction';
import Analysis from './pages/patient/Analysis';
import Medications from './pages/patient/Medications';
import Questionnaire from './pages/patient/Questionnaire';
import Vaccination from './pages/patient/Vaccination';
import Profile from './pages/patient/Profile';
import Advice from './pages/patient/Advice';
import CopdHealthReview from './pages/patient/CopdHealthReview';
import MyAnalysis from './pages/patient/MyAnalysis';
import PulmonaryRehab from './pages/patient/PulmonaryRehab';
import Appointments from './pages/patient/Appointments';
import Reminders from './pages/patient/Reminders';
import DoctorPatients from './pages/doctor/PatientList';
import DoctorPatientDetails from './pages/doctor/SubmitReport';
import DoctorPftValues from './pages/doctor/PftValues';
import DoctorABGReport from './pages/doctor/ABGReport';
import DoctorMedication from './pages/doctor/Medication';
import DoctorInhalerAdherence from './pages/doctor/InhalerAdherence';
import DoctorSixMinWalk from './pages/doctor/SixMinWalkTest';
import DoctorAppointments from './pages/doctor/Appointments';
import DoctorReports from './pages/doctor/Reports';
import DoctorReportSearch from './pages/doctor/ReportSearch';
import DoctorVideos from './pages/doctor/Videos';
import DoctorProfile from './pages/doctor/Profile';
import DoctorNotifications from './pages/doctor/Notifications';

// Shared Components
import ProtectedRoute from './components/ProtectedRoute';
import PatientLayout from './layouts/PatientLayout';
import DoctorLayout from './layouts/DoctorLayout';

const AppRoutes = () => {
  return (
    <Routes>
      <Route path="/" element={<Welcome />} />
      <Route path="/select-role" element={<RoleSelection />} />

      {/* Patient Routes */}
      <Route path="/patient/login" element={<PatientLogin />} />
      <Route path="/patient/signup" element={<PatientSignup />} />
      <Route path="/patient/forgot-password" element={<ForgotPassword />} />
      <Route path="/patient/recover-id" element={<RecoverPatientId />} />

      <Route path="/patient/*" element={
        <ProtectedRoute role="patient">
          <PatientLayout>
            <Routes>
              <Route path="dashboard" element={<PatientDashboard />} />
              <Route path="checkup" element={<TempCheck />} />
              <Route path="checkup/oxygen" element={<OxygenCheck />} />
              <Route path="checkup/lung" element={<LungFunction />} />
              <Route path="analysis" element={<Analysis />} />
              <Route path="meds" element={<Medications />} />
              <Route path="questionnaire" element={<Questionnaire />} />
              <Route path="vaccination" element={<Vaccination />} />
              <Route path="profile" element={<Profile />} />
              <Route path="advice" element={<Advice />} />
              <Route path="advice/review" element={<CopdHealthReview />} />
              <Route path="advice/analysis" element={<MyAnalysis />} />
              <Route path="rehab" element={<PulmonaryRehab />} />
              <Route path="appointments" element={<Appointments />} />
              <Route path="reminders" element={<Reminders />} />
            </Routes>
          </PatientLayout>
        </ProtectedRoute>
      } />

      {/* Doctor Routes */}
      <Route path="/doctor/login" element={<DoctorLogin />} />
      <Route path="/doctor/forgot-password" element={<DoctorForgotPassword />} />
      <Route path="/doctor/*" element={
        <ProtectedRoute role="doctor">
          <DoctorLayout>
            <Routes>
              <Route path="dashboard" element={<DoctorDashboard />} />
              <Route path="patients" element={<DoctorPatients />} />
              <Route path="patients/:id" element={<DoctorPatientDetails />} />
              <Route path="submit/pft/:id" element={<DoctorPftValues />} />
              <Route path="submit/abg/:id" element={<DoctorABGReport />} />
              <Route path="submit/meds/:id" element={<DoctorMedication />} />
              <Route path="submit/adherence/:id" element={<DoctorInhalerAdherence />} />
              <Route path="submit/walk/:id" element={<DoctorSixMinWalk />} />
              <Route path="appointments" element={<DoctorAppointments />} />
              <Route path="search" element={<DoctorReportSearch />} />
              <Route path="reports/:id" element={<DoctorReports />} />
              <Route path="videos" element={<DoctorVideos />} />
              <Route path="profile" element={<DoctorProfile />} />
              <Route path="notifications" element={<DoctorNotifications />} />
            </Routes>
          </DoctorLayout>
        </ProtectedRoute>
      } />

      {/* Redirect unknown routes */}
      <Route path="*" element={<Navigate to="/" replace />} />
    </Routes>
  );
};

function App() {
  return (
    <AuthProvider>
      <CheckupProvider>
        <Router>
          <AppRoutes />
        </Router>
      </CheckupProvider>
    </AuthProvider>
  );
}

export default App;
