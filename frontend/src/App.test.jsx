import { render, screen, waitFor } from '@testing-library/react';
import { afterEach, describe, expect, it, vi } from 'vitest';
import App from './App.jsx';

afterEach(() => vi.restoreAllMocks());

describe('App', () => {
  it('renders tasks returned by the API', async () => {
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue({
      ok: true, status: 200,
      json: async () => [{ id: 1, title: 'Write Jenkinsfile', done: false }],
    }));
    render(<App />);
    await waitFor(() => expect(screen.getByText(/Write Jenkinsfile/)).toBeInTheDocument());
  });

  it('shows an error when the API fails', async () => {
    vi.stubGlobal('fetch', vi.fn().mockResolvedValue({ ok: false, status: 500, json: async () => ({}) }));
    render(<App />);
    await waitFor(() => expect(screen.getByRole('alert')).toHaveTextContent('API 500'));
  });
});
