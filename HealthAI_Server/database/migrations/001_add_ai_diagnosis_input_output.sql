-- Migration: Add input_data and output_data columns to ai_diagnoses table
-- Created: 2026-01-04
-- Description: Store full input features and model output for AI diagnosis traceability

BEGIN;

-- Add input_data column to store all input features
ALTER TABLE ai_diagnoses 
ADD COLUMN IF NOT EXISTS input_data JSONB;

-- Add output_data column to store complete model output (probabilities, classes)
ALTER TABLE ai_diagnoses 
ADD COLUMN IF NOT EXISTS output_data JSONB;

-- Create indexes for JSONB columns for better query performance
CREATE INDEX IF NOT EXISTS idx_ai_diagnoses_input_data ON ai_diagnoses USING gin(input_data);
CREATE INDEX IF NOT EXISTS idx_ai_diagnoses_output_data ON ai_diagnoses USING gin(output_data);

COMMIT;
