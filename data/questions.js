const allQuestions = Array.from({ length: 11 }, (_, i) => window[`allQuestions${i + 1}`] || [])
                        .flat();
