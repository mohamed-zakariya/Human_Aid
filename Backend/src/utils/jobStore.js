const jobs = new Map(); // In-memory job store

function createJob(initialData = {}) {
  const id = crypto.randomUUID();
  jobs.set(id, { status: 'pending', result: null, error: null, ...initialData });
  return id;
}

function getJob(id) {
  return jobs.get(id);
}

function completeJob(id, result) {
  if (jobs.has(id)) jobs.set(id, { ...jobs.get(id), status: 'completed', result });
}

function failJob(id, error) {
  if (jobs.has(id)) jobs.set(id, { ...jobs.get(id), status: 'error', error });
}

export default { createJob, getJob, completeJob, failJob };
