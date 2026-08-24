-- CreateEnum
CREATE TYPE "UserRole" AS ENUM ('SUPER_ADMIN', 'OPS_MANAGER', 'SECURITY_OFFICER', 'TECHNICIAN', 'PARTNER_ADMIN', 'PASSENGER');

-- CreateEnum
CREATE TYPE "SeatStatus" AS ENUM ('AVAILABLE', 'RESERVED', 'PREPARATION', 'READY', 'ASSIGNED', 'INSTALLED', 'ACTIVE_RENTAL', 'RETURNED', 'CLEANING', 'INSPECTION', 'QUARANTINE', 'RETIRED');

-- CreateEnum
CREATE TYPE "BookingStatus" AS ENUM ('NEW', 'ALLOCATED', 'PREPARATION', 'READY', 'TECHNICIAN_ASSIGNED', 'EN_ROUTE', 'INSTALLED', 'FAMILY_READY', 'ACTIVE_RENTAL', 'RETURNED', 'CLEANING', 'INSPECTION', 'CANCELLED', 'COMPLETED');

-- CreateEnum
CREATE TYPE "SeatCategory" AS ENUM ('INFANT_CARRIER', 'INFANT', 'TODDLER', 'BOOSTER', 'STROLLER_LIGHT', 'STROLLER_RECON');

-- CreateEnum
CREATE TYPE "ChildAgeBand" AS ENUM ('NEWBORN_0_3M', 'INFANT_0_1', 'TODDLER_1_4', 'CHILD_4_12');

-- CreateEnum
CREATE TYPE "CleaningStep" AS ENUM ('INITIAL_INSPECTION', 'CLEANING', 'DRYING', 'REASSEMBLY', 'FINAL_INSPECTION');

-- CreateEnum
CREATE TYPE "InspectionStep" AS ENUM ('INITIAL', 'FINAL');

-- CreateEnum
CREATE TYPE "IncidentStatus" AS ENUM ('OPEN', 'IN_PROGRESS', 'RESOLVED', 'CLOSED');

-- CreateEnum
CREATE TYPE "PaymentStatus" AS ENUM ('UNPAID', 'PAID', 'OVERDUE');

-- CreateEnum
CREATE TYPE "FlightStatusEnum" AS ENUM ('SCHEDULED', 'DELAYED', 'EARLY', 'LANDED', 'CANCELLED', 'DIVERTED');

-- CreateEnum
CREATE TYPE "ScanType" AS ENUM ('INTERNAL', 'PUBLIC');

-- CreateEnum
CREATE TYPE "AdjustmentType" AS ENUM ('REFUND', 'CHARGEBACK', 'MANUAL_ADJUSTMENT', 'CANCELLATION_FEE');

-- CreateTable
CREATE TABLE "UserProfile" (
    "id" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "role" "UserRole" NOT NULL,
    "partnerId" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "UserProfile_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Partner" (
    "id" TEXT NOT NULL,
    "name" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Partner_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PartnerSettings" (
    "id" TEXT NOT NULL,
    "partnerId" TEXT NOT NULL,
    "defaultPartnerShare" DECIMAL(5,2) NOT NULL DEFAULT 0.30,
    "launchEnabled" BOOLEAN NOT NULL DEFAULT false,
    "launchPartnerShare" DECIMAL(5,2) NOT NULL DEFAULT 0.50,
    "launchCreditTarget" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "launchCreditAccrued" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "onboardingCredit" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "annualProgramFee" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PartnerSettings_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PartnerRoiInput" (
    "id" TEXT NOT NULL,
    "partnerId" TEXT NOT NULL,
    "seatPurchaseCost" DECIMAL(10,2),
    "cleaningCost" DECIMAL(10,2),
    "storageCost" DECIMAL(10,2),
    "staffHandlingMinutes" INTEGER,
    "hourlyEmployeeCost" DECIMAL(10,2),
    "annualReplacementCost" DECIMAL(10,2),
    "refunds" DECIMAL(10,2),
    "compensation" DECIMAL(10,2),
    "childSeatPrice" DECIMAL(10,2),
    "familyBookingConversion" DECIMAL(5,2),
    "vehicleRentalContribution" DECIMAL(10,2),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "PartnerRoiInput_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Booking" (
    "id" TEXT NOT NULL,
    "partnerId" TEXT NOT NULL,
    "externalBookingNumber" TEXT,
    "locationAirport" TEXT NOT NULL,
    "pickupDateTime" TIMESTAMP(3) NOT NULL,
    "returnDateTime" TIMESTAMP(3) NOT NULL,
    "flightNumber" TEXT,
    "scheduledArrival" TIMESTAMP(3),
    "estimatedArrival" TIMESTAMP(3),
    "actualArrival" TIMESTAMP(3),
    "seatCategory" "SeatCategory" NOT NULL,
    "childAgeBand" "ChildAgeBand",
    "childHeight" TEXT,
    "vehicle" TEXT,
    "vehicleBay" TEXT,
    "assignedSeatId" TEXT,
    "assignedTechnicianId" TEXT,
    "dailyRate" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "paidDays" INTEGER NOT NULL DEFAULT 0,
    "grossRevenue" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "partnerShare" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "platformShare" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "status" "BookingStatus" NOT NULL DEFAULT 'NEW',
    "incidentStatus" TEXT,
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Booking_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "BookingStatusHistory" (
    "id" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "status" "BookingStatus" NOT NULL,
    "changedBy" TEXT NOT NULL,
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "BookingStatusHistory_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Seat" (
    "id" TEXT NOT NULL,
    "publicToken" TEXT NOT NULL,
    "qrCodeData" TEXT,
    "manufacturer" TEXT,
    "model" TEXT,
    "category" "SeatCategory" NOT NULL,
    "safetyCertification" TEXT,
    "manufactureDate" TIMESTAMP(3),
    "purchaseDate" TIMESTAMP(3),
    "currentLocation" TEXT,
    "warehousePosition" TEXT,
    "status" "SeatStatus" NOT NULL DEFAULT 'AVAILABLE',
    "rentalCycles" INTEGER NOT NULL DEFAULT 0,
    "maxRentalCycles" INTEGER,
    "lastCleaningDate" TIMESTAMP(3),
    "lastInspectionDate" TIMESTAMP(3),
    "partnerId" TEXT NOT NULL,
    "retirementStatus" BOOLEAN NOT NULL DEFAULT false,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Seat_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SeatStatusHistory" (
    "id" TEXT NOT NULL,
    "seatId" TEXT NOT NULL,
    "status" "SeatStatus" NOT NULL,
    "changedBy" TEXT NOT NULL,
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "SeatStatusHistory_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "CleaningLog" (
    "id" TEXT NOT NULL,
    "seatId" TEXT NOT NULL,
    "bookingId" TEXT,
    "employeeId" TEXT NOT NULL,
    "step" "CleaningStep" NOT NULL,
    "checklist" JSONB,
    "passed" BOOLEAN NOT NULL,
    "notes" TEXT,
    "photoUrl" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "CleaningLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "InspectionLog" (
    "id" TEXT NOT NULL,
    "seatId" TEXT NOT NULL,
    "bookingId" TEXT,
    "employeeId" TEXT NOT NULL,
    "step" "InspectionStep" NOT NULL,
    "checklist" JSONB,
    "passed" BOOLEAN NOT NULL,
    "notes" TEXT,
    "photoUrl" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "InspectionLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "DamageRecord" (
    "id" TEXT NOT NULL,
    "seatId" TEXT NOT NULL,
    "description" TEXT NOT NULL,
    "reportedBy" TEXT NOT NULL,
    "reportedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "resolved" BOOLEAN NOT NULL DEFAULT false,
    "resolvedAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "DamageRecord_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "QuarantineRecord" (
    "id" TEXT NOT NULL,
    "seatId" TEXT NOT NULL,
    "reason" TEXT NOT NULL,
    "startDate" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "endDate" TIMESTAMP(3),
    "notes" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "QuarantineRecord_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "TechnicianAssignment" (
    "id" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "technicianId" TEXT NOT NULL,
    "status" TEXT NOT NULL DEFAULT 'PENDING',
    "assignedAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "TechnicianAssignment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "InstallationRecord" (
    "id" TEXT NOT NULL,
    "assignmentId" TEXT NOT NULL,
    "checklist" JSONB,
    "photoUrl" TEXT,
    "vehicleBay" TEXT,
    "completedAt" TIMESTAMP(3),
    "familyReadyAt" TIMESTAMP(3),
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "InstallationRecord_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "SeatScanLog" (
    "id" TEXT NOT NULL,
    "seatId" TEXT NOT NULL,
    "scannedBy" TEXT NOT NULL,
    "scanType" "ScanType" NOT NULL,
    "bookingId" TEXT,
    "result" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "SeatScanLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FlightStatus" (
    "id" TEXT NOT NULL,
    "flightNumber" TEXT NOT NULL,
    "scheduledArrival" TIMESTAMP(3) NOT NULL,
    "estimatedArrival" TIMESTAMP(3),
    "actualArrival" TIMESTAMP(3),
    "delayMinutes" INTEGER NOT NULL DEFAULT 0,
    "earlyMinutes" INTEGER NOT NULL DEFAULT 0,
    "status" "FlightStatusEnum" NOT NULL DEFAULT 'SCHEDULED',
    "terminal" TEXT,
    "bookingId" TEXT,
    "partnerId" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "FlightStatus_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Invoice" (
    "id" TEXT NOT NULL,
    "partnerId" TEXT NOT NULL,
    "invoiceNumber" TEXT NOT NULL,
    "periodStart" TIMESTAMP(3) NOT NULL,
    "periodEnd" TIMESTAMP(3) NOT NULL,
    "subtotal" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "vatRate" DECIMAL(5,2) NOT NULL DEFAULT 0,
    "vatAmount" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "total" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "dueDate" TIMESTAMP(3) NOT NULL,
    "status" "PaymentStatus" NOT NULL DEFAULT 'UNPAID',
    "pdfUrl" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Invoice_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Settlement" (
    "id" TEXT NOT NULL,
    "partnerId" TEXT NOT NULL,
    "bookingId" TEXT NOT NULL,
    "invoiceId" TEXT,
    "grossRevenue" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "partnerShare" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "platformShare" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "launchCreditUsed" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "launchCreditRemaining" DECIMAL(10,2) NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Settlement_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "FinancialAdjustment" (
    "id" TEXT NOT NULL,
    "partnerId" TEXT NOT NULL,
    "bookingId" TEXT,
    "type" "AdjustmentType" NOT NULL,
    "amount" DECIMAL(10,2) NOT NULL,
    "reason" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "FinancialAdjustment_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "Incident" (
    "id" TEXT NOT NULL,
    "partnerId" TEXT NOT NULL,
    "bookingId" TEXT,
    "description" TEXT NOT NULL,
    "severity" TEXT,
    "status" "IncidentStatus" NOT NULL DEFAULT 'OPEN',
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Incident_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AuditLog" (
    "id" TEXT NOT NULL,
    "tableName" TEXT NOT NULL,
    "recordId" TEXT NOT NULL,
    "action" TEXT NOT NULL,
    "oldData" JSONB,
    "newData" JSONB,
    "changedBy" TEXT,
    "ipAddress" TEXT,
    "userAgent" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AuditLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "PartnerLog" (
    "id" TEXT NOT NULL,
    "partnerId" TEXT NOT NULL,
    "message" TEXT NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "PartnerLog_pkey" PRIMARY KEY ("id")
);

-- CreateTable
CREATE TABLE "AiQueryLog" (
    "id" TEXT NOT NULL,
    "partnerId" TEXT NOT NULL,
    "question" TEXT NOT NULL,
    "answer" JSONB,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "AiQueryLog_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "UserProfile_userId_key" ON "UserProfile"("userId");

-- CreateIndex
CREATE UNIQUE INDEX "PartnerSettings_partnerId_key" ON "PartnerSettings"("partnerId");

-- CreateIndex
CREATE UNIQUE INDEX "PartnerRoiInput_partnerId_key" ON "PartnerRoiInput"("partnerId");

-- CreateIndex
CREATE INDEX "Booking_partnerId_status_idx" ON "Booking"("partnerId", "status");

-- CreateIndex
CREATE INDEX "Booking_partnerId_pickupDateTime_idx" ON "Booking"("partnerId", "pickupDateTime");

-- CreateIndex
CREATE UNIQUE INDEX "Seat_publicToken_key" ON "Seat"("publicToken");

-- CreateIndex
CREATE INDEX "Seat_partnerId_status_idx" ON "Seat"("partnerId", "status");

-- CreateIndex
CREATE INDEX "Seat_publicToken_idx" ON "Seat"("publicToken");

-- CreateIndex
CREATE UNIQUE INDEX "InstallationRecord_assignmentId_key" ON "InstallationRecord"("assignmentId");

-- CreateIndex
CREATE UNIQUE INDEX "FlightStatus_bookingId_key" ON "FlightStatus"("bookingId");

-- CreateIndex
CREATE INDEX "FlightStatus_partnerId_estimatedArrival_scheduledArrival_idx" ON "FlightStatus"("partnerId", "estimatedArrival", "scheduledArrival");

-- AddForeignKey
ALTER TABLE "UserProfile" ADD CONSTRAINT "UserProfile_partnerId_fkey" FOREIGN KEY ("partnerId") REFERENCES "Partner"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PartnerSettings" ADD CONSTRAINT "PartnerSettings_partnerId_fkey" FOREIGN KEY ("partnerId") REFERENCES "Partner"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "PartnerRoiInput" ADD CONSTRAINT "PartnerRoiInput_partnerId_fkey" FOREIGN KEY ("partnerId") REFERENCES "Partner"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_partnerId_fkey" FOREIGN KEY ("partnerId") REFERENCES "Partner"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_assignedSeatId_fkey" FOREIGN KEY ("assignedSeatId") REFERENCES "Seat"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Booking" ADD CONSTRAINT "Booking_assignedTechnicianId_fkey" FOREIGN KEY ("assignedTechnicianId") REFERENCES "UserProfile"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "BookingStatusHistory" ADD CONSTRAINT "BookingStatusHistory_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Seat" ADD CONSTRAINT "Seat_partnerId_fkey" FOREIGN KEY ("partnerId") REFERENCES "Partner"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SeatStatusHistory" ADD CONSTRAINT "SeatStatusHistory_seatId_fkey" FOREIGN KEY ("seatId") REFERENCES "Seat"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CleaningLog" ADD CONSTRAINT "CleaningLog_seatId_fkey" FOREIGN KEY ("seatId") REFERENCES "Seat"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "CleaningLog" ADD CONSTRAINT "CleaningLog_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "InspectionLog" ADD CONSTRAINT "InspectionLog_seatId_fkey" FOREIGN KEY ("seatId") REFERENCES "Seat"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "InspectionLog" ADD CONSTRAINT "InspectionLog_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "DamageRecord" ADD CONSTRAINT "DamageRecord_seatId_fkey" FOREIGN KEY ("seatId") REFERENCES "Seat"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "QuarantineRecord" ADD CONSTRAINT "QuarantineRecord_seatId_fkey" FOREIGN KEY ("seatId") REFERENCES "Seat"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TechnicianAssignment" ADD CONSTRAINT "TechnicianAssignment_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "TechnicianAssignment" ADD CONSTRAINT "TechnicianAssignment_technicianId_fkey" FOREIGN KEY ("technicianId") REFERENCES "UserProfile"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "InstallationRecord" ADD CONSTRAINT "InstallationRecord_assignmentId_fkey" FOREIGN KEY ("assignmentId") REFERENCES "TechnicianAssignment"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SeatScanLog" ADD CONSTRAINT "SeatScanLog_seatId_fkey" FOREIGN KEY ("seatId") REFERENCES "Seat"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "SeatScanLog" ADD CONSTRAINT "SeatScanLog_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FlightStatus" ADD CONSTRAINT "FlightStatus_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FlightStatus" ADD CONSTRAINT "FlightStatus_partnerId_fkey" FOREIGN KEY ("partnerId") REFERENCES "Partner"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Invoice" ADD CONSTRAINT "Invoice_partnerId_fkey" FOREIGN KEY ("partnerId") REFERENCES "Partner"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Settlement" ADD CONSTRAINT "Settlement_partnerId_fkey" FOREIGN KEY ("partnerId") REFERENCES "Partner"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Settlement" ADD CONSTRAINT "Settlement_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Settlement" ADD CONSTRAINT "Settlement_invoiceId_fkey" FOREIGN KEY ("invoiceId") REFERENCES "Invoice"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FinancialAdjustment" ADD CONSTRAINT "FinancialAdjustment_partnerId_fkey" FOREIGN KEY ("partnerId") REFERENCES "Partner"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "FinancialAdjustment" ADD CONSTRAINT "FinancialAdjustment_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Incident" ADD CONSTRAINT "Incident_partnerId_fkey" FOREIGN KEY ("partnerId") REFERENCES "Partner"("id") ON DELETE RESTRICT ON UPDATE CASCADE;

-- AddForeignKey
ALTER TABLE "Incident" ADD CONSTRAINT "Incident_bookingId_fkey" FOREIGN KEY ("bookingId") REFERENCES "Booking"("id") ON DELETE SET NULL ON UPDATE CASCADE;
