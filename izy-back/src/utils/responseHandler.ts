import { Response } from 'express';

interface ApiResponse<T> {
  code: number;
  message: 'success' | 'failed';
  messagecode: string;
  data: T | null;
  error: string | null;
}

export const sendResponse = <T>(
  res: Response,
  code: number,
  message: 'success' | 'failed',
  messagecode: string,
  data: T | null = null,
  error: string | null = null
) => {
  const response: ApiResponse<T> = {
    code,
    message,
    messagecode,
    data,
    error,
  };

  return res.status(code).json(response);
};